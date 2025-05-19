//
//  LaunchesViewModel.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import ReactorKit
import Combine

final class LaunchesViewModel: Reactor {
    
    // MARK: - Typealiases
    
    typealias LaunchesState = FetchingState<[LaunchResult], AppError>
    
    // MARK: - Enums
    
    /// Modes for launch picker (All launches or Saved launches)
    enum LaunchPickerMode: CaseIterable, Identifiable, CustomStringConvertible {
        case all
        case saved
        
        var id: Self { self }
        
        var description: String {
            switch self {
            case .all: return String(localized: "picker.all")
            case .saved: return String(localized: "picker.saved")
            }
        }
    }
    
    /// Actions user can perform
    enum Action {
        case fetchLaunches(isPullToRefresh: Bool)
        case paginate
        case setSelectedLaunch(LaunchResult?)
        case toggleLaunch(LaunchResult)
        case setPickerMode(LaunchPickerMode)
        case setRealtimeSavedLaunches([LaunchResult])
        case setSearchText(String)
    }
    
    /// State changes (mutations) that update the ViewModel's state
    enum Mutation {
        case didUpdateFetchingState(LaunchesState)
        case didUpdateIsPaginating(Bool)
        case didUpdatePaginatingURL(URL?)
        case didUpdateSelectedLaunch(LaunchResult?)
        case didUpdatePickerMode(LaunchPickerMode)
        case didUpdateRealtimeSavedLaunches([LaunchResult])
        case didUpdateFetchedLaunches([LaunchResult])
        case didUpdateSearchText(String)
    }
    
    // MARK: - State
    
    struct State {
        var fetchingState: LaunchesState = .idle
        var paginatingUrl: URL?
        var isPaginating = false
        var selectedLaunch: LaunchResult?
        var pickerMode: LaunchPickerMode = .all
        
        /// Cached saved launches from shared cache manager
        var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
        
        /// Filter saved launches based on search text
        var filteredSavedLaunches: [LaunchResult] {
            guard !searchText.isEmpty else { return self.savedLaunches }
            return self.savedLaunches.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        var fetchedLaunches: [LaunchResult] = []
        var searchText: String = ""
    }
    
    // MARK: - Properties
    
    var initialState: State
    
    // MARK: - Initialization
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    // MARK: - Transformations
    
    /// Transforms incoming Actions by debouncing search text input and merging other actions.
    func transform(action: Observable<Action>) -> Observable<Action> {
        // Debounce search text input to reduce excessive fetch requests
        let debouncedSearch = action
            .compactMap { action -> String? in
                guard case let .setSearchText(text) = action else { return nil }
                return text
            }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMap { text in
                Observable.from([
                    Action.setSearchText(text),
                    Action.fetchLaunches(isPullToRefresh: false)
                ])
            }
        
        // Pass through all actions except search text (which is handled by debounce)
        let passthrough = action.filter {
            if case .setSearchText = $0 { return false }
            return true
        }
        
        // Merge passthrough actions, debounced search actions,
        // and initial fetch + deselect launch at startup
        return Observable.merge(
            passthrough,
            debouncedSearch,
            Observable.just(.fetchLaunches(isPullToRefresh: false)),
            Observable.just(.setSelectedLaunch(nil))
        )
    }
    
    /// Transforms Mutations by merging cache updates for saved launches when no launch is selected
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge(
            mutation,
            CacheManager.shared.savedLaunchesPublisher
                .filter { _ in self.currentState.selectedLaunch == nil }
                .asObservable()
                .map { .didUpdateRealtimeSavedLaunches($0) }
        )
    }
    
    // MARK: - Mutation Handling
    
    /// Handles Actions by returning Observable Mutations
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunches(let isPullToRefresh):
            return fetchLaunches(isPullToRefresh: isPullToRefresh)
            
        case .paginate:
            return paginate()
            
        case .setSelectedLaunch(let selectedLaunch):
            return .just(.didUpdateSelectedLaunch(selectedLaunch))
            
        case .setPickerMode(let mode):
            return .just(.didUpdatePickerMode(mode))
            
        case .setRealtimeSavedLaunches(let savedLaunches):
            return .just(.didUpdateRealtimeSavedLaunches(savedLaunches))
            
        case .setSearchText(let text):
            return .just(.didUpdateSearchText(text))
            
        case .toggleLaunch(let launch):
            // Toggle launch saved state and notifications, no mutation emitted
            CacheManager.shared.toggleSavedLaunch(launch)
            NotificationManager.shared.toggleLaunchNotification(launch: launch)
            return .never()
        }
    }
    
    // MARK: - State Reduction
    
    /// Reduces mutations into a new state
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateFetchingState(let fetchingState):
            state.fetchingState = fetchingState
            
        case .didUpdateIsPaginating(let isPaginating):
            state.isPaginating = isPaginating
            
        case .didUpdatePaginatingURL(let paginatingURL):
            state.paginatingUrl = paginatingURL
            
        case .didUpdateSelectedLaunch(let selectedLaunch):
            state.selectedLaunch = selectedLaunch
            // Refresh saved launches if no launch selected (reset detail)
            guard selectedLaunch == nil else { break }
            state.savedLaunches = CacheManager.shared.savedLaunches
            
        case .didUpdatePickerMode(let mode):
            state.pickerMode = mode
            
        case .didUpdateRealtimeSavedLaunches(let savedLaunches):
            // Update saved launches only if no launch selected
            guard currentState.selectedLaunch == nil else { break }
            state.savedLaunches = savedLaunches.sorted {
                ($0.netDate ?? .distantFuture) < ($1.netDate ?? .distantFuture)
            }
            
        case .didUpdateFetchedLaunches(let fetchedLaunches):
            state.fetchedLaunches = fetchedLaunches
            
        case .didUpdateSearchText(let text):
            state.searchText = text
        }
        
        return state
    }
    
    // MARK: - Private Networking Methods
    
    /// Fetch launches from the server with optional pull-to-refresh delay
    func fetchLaunches(isPullToRefresh: Bool) -> Observable<Mutation> {
        let delayDuration = isPullToRefresh ? 1.8 : 0.0
        
        // Show loading state (with delay for pull-to-refresh UX)
        let loadingPublisher: Observable<Mutation> = {
            if !isPullToRefresh {
                return Observable.just(Mutation.didUpdateFetchingState(.loading))
            } else {
                return Observable.just(.didUpdateFetchingState(currentState.fetchingState))
                    .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            }
        }()
        
        return Observable.concat([
            loadingPublisher,
            RequestManager.shared.fetchLaunches(search: self.currentState.searchText)
                .flatMap { response -> Observable<Mutation> in
                    let stateMutation = Mutation.didUpdateFetchingState(.success(response.results))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(response.results)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdateFetchingState(.error(error as? AppError ?? .unknown)))
                }
        ])
    }
    
    /// Load next page of launches (pagination)
    func paginate() -> Observable<Mutation> {
        guard let url = currentState.paginatingUrl else {
            return .empty() // No more pages to load
        }
        
        return Observable.concat([
            Observable.just(Mutation.didUpdateIsPaginating(true)),
            
            RequestManager.shared.paginate(url: url, search: self.currentState.searchText)
                .flatMap { response in
                    var combinedResults = self.currentState.fetchedLaunches
                    for launch in response.results {
                        if !combinedResults.contains(launch) {
                            combinedResults.append(launch)
                        }
                    }
                    
                    let stateMutation = Mutation.didUpdateFetchingState(.success(combinedResults))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(combinedResults)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdateFetchingState(.error(error as? AppError ?? .unknown)))
                },
            
            Observable.just(Mutation.didUpdateIsPaginating(false))
        ])
    }
}
