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
    
    enum Action {
        case updateSavedLaunches
        case openLaunch(LaunchResult)
    }
    
    enum Mutation {
        case didUpdateSavedLaunches([LaunchResult])
        case didUpdateRemainingTime(Double)
    }
    
    struct State {
        var savedLaunches: [LaunchResult]
        var remainingTime: Double
        
        var nextUpcomingLaunch: LaunchResult? {
            savedLaunches
                .filter { $0.netDate ?? .distantFuture > Date() }
                .sorted { ($0.netDate ?? .distantFuture) < ($1.netDate ?? .distantFuture) }
                .first
        }
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(savedLaunches: CacheManager.shared.savedLaunches, remainingTime: 0.0)
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let publisher = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .compactMap { [weak self] _ in self?.currentState.nextUpcomingLaunch?.netDate }
            .asObservable()
        
        return Observable.merge(
            mutation,
            publisher.map { .didUpdateRemainingTime($0.timeIntervalSinceNow) },
            CacheManager.shared.savedLaunchesPublisher.asObservable().map { .didUpdateSavedLaunches($0) }
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateSavedLaunches:
            return Observable.just(Mutation.didUpdateSavedLaunches(CacheManager.shared.savedLaunches))
            
        case .openLaunch(let launch):
            NavigationManager.shared.navigateTo(launch)
            return .never()
        }
    }
    
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
