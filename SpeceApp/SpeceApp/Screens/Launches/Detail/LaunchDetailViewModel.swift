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
    
    typealias LaunchesState = FetchingState<LaunchDetailResult, AppError>
    
    enum Action {
        case fetchLaunchDetail(id: String)
        case refreshLaunchDetail
        case toggleSavedLaunch
        case updateCountdownNow
        case showOnMap(MapPointLocation)
    }
    
    enum Mutation {
        case didUpdatefetchingState(LaunchesState)
        case didToggleSavedState
        case didUpdateRemainingTime(Double)
    }
    
    struct State {
        var fetchingState: LaunchesState = .idle
        let launch: LaunchResult
        var isSaved: Bool
        
        var remainingTime: Double = 0.0
    }
    
    var initialState: State
    
    private var timerCancellable: AnyCancellable?
    
    init(launch: LaunchResult) {
        self.initialState = State(fetchingState: .loading, launch: launch, isSaved: CacheManager.shared.savedLaunches.contains(launch))
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
    
        return Observable.merge(
            action,
            Observable.just(.fetchLaunchDetail(id: currentState.launch.id))
        )
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let publisher = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .compactMap { [weak self] _ in self?.currentState.fetchingState.successValue?.netDate }
            .asObservable()
        
        return Observable.merge(
            mutation,
            CacheManager.shared.savedLaunchedPublisher.asObservable().map { _ in .didToggleSavedState },
            publisher.map { .didUpdateRemainingTime($0.timeIntervalSinceNow) }
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunchDetail(let id):
            return fetchDetail(id: id)
            
        case .refreshLaunchDetail:
            return fetchDetail(id: currentState.launch.id)
            
        case .toggleSavedLaunch:
            CacheManager.shared.toggleSavedLaunch(currentState.launch)
            return Observable.never()
        case .updateCountdownNow:
            return Observable.just(Mutation.didUpdateRemainingTime(currentState.launch.netDate?.timeIntervalSinceNow ?? 0.0))
        case .showOnMap(let mapPointLocation):
            CacheManager.shared.navigateToMapAndShow(mapPointLocation)
            return .never()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdatefetchingState(let fetchingState):
            state.fetchingState = fetchingState
            
        case .didToggleSavedState:
            state.isSaved = CacheManager.shared.savedLaunches.contains(currentState.launch)
            
        case .didUpdateRemainingTime(let remainingTime):
            state.remainingTime = remainingTime
        }
        return state
    }
    
    func fetchDetail(id: String) -> Observable<Mutation> {
        return Observable.concat([
            Observable<Void>.just(())
                .map { Mutation.didUpdatefetchingState(.loading) },
            
            RequestManager.shared.fetchDetailOfLaunch(id: id)
                .flatMap { response -> Observable<Mutation> in
                    let stateMutation = Mutation.didUpdatefetchingState(.success(response))
                    return Observable.from([stateMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdatefetchingState(.error(error as? AppError ?? .unknown)))
                }
        ])
    }
}
