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
    
    typealias LaunchesState = FetchingState<[LaunchResult], AppError>
    
    enum LaunchPickerMode: CaseIterable, Identifiable, CustomStringConvertible {
        case all
        case saved
        
        var id: Self { self }

        var description: String {
            switch self {
            case .all: String(localized: "picker.all")
            case .saved: String(localized: "picker.saved")
            }
        }
    }
    
    enum Action {
        case fetchLaunches(isPullToRefresh: Bool)
        case paginate
        case setSelectedLaunch(LaunchResult?)
        case toggleLaunch(LaunchResult)
        case setPickerMode(LaunchPickerMode)
        case setRealtimeSavedLaunches([LaunchResult])
        case setSearchText(String)
    }
    
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
    
    struct State {
        var fetchingState: LaunchesState = .idle
        var paginatingUrl: URL?
        var isPaginating = false
        var selectedLaunch: LaunchResult?
        var pickerMode: LaunchPickerMode = .all
        var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
        var filteredSavedLaunches: [LaunchResult] {
            guard !searchText.isEmpty else { return self.savedLaunches }
            return self.savedLaunches
                .filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        var fetchedLaunches: [LaunchResult] = []
        var searchText: String = ""
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }

    func transform(action: Observable<Action>) -> Observable<Action> {
        let debouncedSearch = action
            .compactMap {
                guard case let .setSearchText(text) = $0 else { return nil }
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

        let passthrough = action.filter {
            if case .setSearchText = $0 {
                return false
            }
            return true
        }
        
        return Observable.merge(
            passthrough,
            debouncedSearch,
            Observable.just(.fetchLaunches(isPullToRefresh: false)),
            Observable.just(.setSelectedLaunch(nil))
        )
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.merge(
            mutation,
            CacheManager.shared.savedLaunchesPublisher
                .filter { _ in self.currentState.selectedLaunch == nil }
                .asObservable()
                .map { .didUpdateRealtimeSavedLaunches($0) }
        )
    }
    
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
            CacheManager.shared.toggleSavedLaunch(launch)
            NotificationManager.shared.toggleLaunchNotification(launch: launch)
            return .never()
        }
    }
    
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
            guard selectedLaunch == nil else { break }
            state.savedLaunches = CacheManager.shared.savedLaunches
            
            
        case .didUpdatePickerMode(let mode):
            state.pickerMode = mode
            
        case .didUpdateRealtimeSavedLaunches(let savedLaunches):
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
    
    func fetchLaunches(isPullToRefresh: Bool) -> Observable<Mutation> {
        let delayDuration = isPullToRefresh ? 1.8 : 0.0
        
        let loadingPublisher: Observable<Mutation> = {
            if !isPullToRefresh {
                Observable.just(Mutation.didUpdateFetchingState(.loading))
            } else {
                Observable.just(.didUpdateFetchingState(currentState.fetchingState)).delay(.milliseconds(500), scheduler: MainScheduler.instance)
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
                    
                    let stateMutation = Mutation.didUpdateFetchingState(.success(response.results))
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

