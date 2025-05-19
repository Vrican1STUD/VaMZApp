//
//  HomeViewModel.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit

final class HomeViewViewModel: Reactor {
    
    // MARK: - Actions
    
    enum Action {
        case updateSavedLaunches
        case openLaunch(LaunchResult)
    }
    
    // MARK: - Mutations
    
    enum Mutation {
        case didUpdateSavedLaunches([LaunchResult])
        case didUpdateRemainingTime(Double)
    }
    
    // MARK: - State
    
    struct State {
        var savedLaunches: [LaunchResult]
        var remainingTime: Double
        
        /// Returns the next upcoming launch from saved launches based on netDate.
        var nextUpcomingLaunch: LaunchResult? {
            savedLaunches
                .filter { $0.netDate ?? .distantFuture > Date() }
                .sorted { ($0.netDate ?? .distantFuture) < ($1.netDate ?? .distantFuture) }
                .first
        }
    }
    
    // MARK: - Properties
    
    var initialState: State
    
    // MARK: - Initialization
    
    init() {
        self.initialState = State(savedLaunches: CacheManager.shared.savedLaunches, remainingTime: 0.0)
    }
    
    // MARK: - Transform mutations
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        // Timer publishes every second to update remaining time for next launch
        let publisher = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .compactMap { [weak self] _ in self?.currentState.nextUpcomingLaunch?.netDate }
            .asObservable()
        
        // Merge external mutations, timer updates, and cache updates
        return Observable.merge(
            mutation,
            publisher.map { .didUpdateRemainingTime($0.timeIntervalSinceNow) },
            CacheManager.shared.savedLaunchesPublisher.asObservable().map { .didUpdateSavedLaunches($0) }
        )
    }
    
    // MARK: - Mutate actions into mutations
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateSavedLaunches:
            return Observable.just(Mutation.didUpdateSavedLaunches(CacheManager.shared.savedLaunches))
            
        case .openLaunch(let launch):
            NavigationManager.shared.navigateTo(launch)
            return .never()
        }
    }
    
    // MARK: - Reduce mutations into new state
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateSavedLaunches(let savedLaunches):
            state.savedLaunches = savedLaunches
            
        case .didUpdateRemainingTime(let remainingTime):
            state.remainingTime = remainingTime
        }
        return state
    }
}
