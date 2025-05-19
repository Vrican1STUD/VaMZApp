//
//  LaunchDetailViewModel.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import SwiftUI
import Combine
import ReactorKit

final class LaunchDetailViewModel: Reactor {
    
    // MARK: - Typealiases
    
    typealias LaunchesState = FetchingState<LaunchDetailResult, AppError>
    
    // MARK: - Actions
    
    enum Action {
        case fetchLaunchDetail(id: String)
        case refreshLaunchDetail
        case toggleSavedLaunch
        case updateCountdownNow
        case showOnMap(MapPointLocation)
    }
    
    // MARK: - Mutations
    
    enum Mutation {
        case didUpdateFetchingState(LaunchesState)
        case didToggleSavedState
        case didUpdateRemainingTime(Double)
    }
    
    // MARK: - State
    
    struct State {
        var fetchingState: LaunchesState = .idle
        let launch: LaunchResult
        var isSaved: Bool
        var remainingTime: Double = 0.0
    }
    
    // MARK: - Properties
    
    var initialState: State
    
    // MARK: - Initialization
    
    init(launch: LaunchResult) {
        self.initialState = State(
            fetchingState: .loading,
            launch: launch,
            isSaved: CacheManager.shared.savedLaunches.contains(launch)
        )
    }
    
    // MARK: - Transformations
    
    /// Automatically triggers fetch action on initialization and merges with user actions
    func transform(action: Observable<Action>) -> Observable<Action> {
        Observable.merge(
            action,
            Observable.just(.fetchLaunchDetail(id: currentState.launch.id))
        )
    }
    
    /// Adds timers and saved launches publisher to mutations stream
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Timer that updates countdown every second if launch date available
        let timerPublisher = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .compactMap { [weak self] _ in
                self?.currentState.fetchingState.successValue?.netDate
            }
            .asObservable()
        
        return Observable.merge(
            mutation,
            // Observe changes to saved launches
            CacheManager.shared.savedLaunchesPublisher.asObservable()
                .map { _ in .didToggleSavedState },
            // Update countdown remaining time every second
            timerPublisher
                .map { .didUpdateRemainingTime($0.timeIntervalSinceNow) }
        )
    }
    
    // MARK: - Mutation Handling
    
    /// Handles incoming actions and produces mutations
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunchDetail(let id):
            return fetchDetail(id: id)
            
        case .refreshLaunchDetail:
            return fetchDetail(id: currentState.launch.id)
            
        case .toggleSavedLaunch:
            CacheManager.shared.toggleSavedLaunch(currentState.launch)
            return .never()
            
        case .updateCountdownNow:
            return Observable.just(Mutation.didUpdateRemainingTime(currentState.launch.netDate?.timeIntervalSinceNow ?? 0.0))
            
        case .showOnMap(let mapPointLocation):
            NavigationManager.shared.navigateToMapAndShow(mapPointLocation)
            return .never()
        }
    }
    
    // MARK: - State Reduction
    
    /// Applies mutations to current state and returns new state
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateFetchingState(let fetchingState):
            state.fetchingState = fetchingState
            
        case .didToggleSavedState:
            state.isSaved = CacheManager.shared.savedLaunches.contains(currentState.launch)
            NotificationManager.shared.toggleLaunchNotification(launch: state.launch)
            
        case .didUpdateRemainingTime(let remainingTime):
            state.remainingTime = remainingTime
        }
        
        return state
    }
    
    // MARK: - Helpers
    
    /// Fetches launch details asynchronously
    func fetchDetail(id: String) -> Observable<Mutation> {
        return Observable.concat([
            // Set fetching state to loading first
            Observable<Void>.just(())
                .map { Mutation.didUpdateFetchingState(.loading) },
            
            // Fetch launch details from the API
            RequestManager.shared.fetchDetailOfLaunch(id: id)
                .flatMap { response -> Observable<Mutation> in
                    let successMutation = Mutation.didUpdateFetchingState(.success(response))
                    return Observable.just(successMutation)
                }
                .catch { error in
                    // Handle error by emitting error state mutation
                    Observable.just(Mutation.didUpdateFetchingState(.error(error as? AppError ?? .unknown)))
                }
        ])
    }
    
    /// Determines whether notification manipulation is allowed for a given date
    func canManipulateNotification(netDate: Date) -> Bool {
        NotificationManager.shared.canManipulateNotification(date: netDate)
    }
}
