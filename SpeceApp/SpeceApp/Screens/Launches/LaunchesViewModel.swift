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
            case .all: "All"
            case .saved: "Saved"
            }
        }
    }
    
    enum Action {
        case fetchLaunches(isPullToRefresh: Bool)
        case paginate
        
        case setSelectedLaunch(LaunchResult?)
        
        case setPickerMode(LaunchPickerMode)
        case setRealtimeSavedLaunches([LaunchResult])
    }
    
    enum Mutation {
        case didUpdatefetchingState(LaunchesState)
        case didUpdateIsPaginating(Bool)
        case didUpdatePaginatingURL(URL?)
        
        case didUpdateSelectedLaunch(LaunchResult?)
        
        case didSetPickerMode(LaunchPickerMode) //set or update
        case didUpdateRealtimeSavedLaunches([LaunchResult])
        case didUpdateFetchedLaunches([LaunchResult])
    }
    
    struct State {
        var fetchingState: LaunchesState = .idle
        var paginatingUrl: URL?
        var isPaginating = false
        var selectedLaunch: LaunchResult?
        
        var pickerMode: LaunchPickerMode = .all
        var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
        var fetchedLaunches: [LaunchResult] = []
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        Observable.merge(
            action,
            Observable.just(.fetchLaunches(isPullToRefresh: false))
        )
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        Observable.merge(
            mutation,
            CacheManager.shared.savedLaunchedPublisher.filter { _ in self.currentState.selectedLaunch == nil }.asObservable().map { .didUpdateRealtimeSavedLaunches($0) })
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
            return .just(.didSetPickerMode(mode))
        case .setRealtimeSavedLaunches(let savedLaunches):
            return .just(.didUpdateRealtimeSavedLaunches(savedLaunches))
        
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdatefetchingState(let fetchingState):
            state.fetchingState = fetchingState
        case .didUpdateIsPaginating(let isPaginating):
            state.isPaginating = isPaginating
        case .didUpdatePaginatingURL(let paginatingURL):
            state.paginatingUrl = paginatingURL
            
        case .didUpdateSelectedLaunch(let selectedLaunch):
            state.selectedLaunch = selectedLaunch
            
        case .didSetPickerMode(let mode):
            state.pickerMode = mode
        case .didUpdateRealtimeSavedLaunches(let savedLaunches):
            guard currentState.selectedLaunch == nil else { break }
            state.savedLaunches = savedLaunches
        case .didUpdateFetchedLaunches(let fetchedLaunches):
            state.fetchedLaunches = fetchedLaunches
        }
        
        return state
    }
    
    func fetchLaunches(isPullToRefresh: Bool) -> Observable<Mutation> {
        let delayDuration = isPullToRefresh ? 1.8 : 0.0
        
        let loadingPublisher: Observable<Mutation> = {
            if !isPullToRefresh {
                Observable.just(Mutation.didUpdatefetchingState(.loading))
            } else {
                Observable.just(.didUpdatefetchingState(currentState.fetchingState)).delay(.milliseconds(500), scheduler: MainScheduler.instance)
            }
        }()
        
        return Observable.concat([
            loadingPublisher,
            RequestManager.shared.fetchLaunches()
                .flatMap { response -> Observable<Mutation> in
                    let stateMutation = Mutation.didUpdatefetchingState(.success(response.results))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(response.results)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdatefetchingState(.error(error as? AppError ?? .unknown)))
                }
        ])
    }
    
    func paginate() -> Observable<Mutation> {
        guard let url = currentState.paginatingUrl else {
            return .empty() // No more pages to load
        }
        
        return Observable.concat([
            Observable.just(Mutation.didUpdateIsPaginating(true)),
            
            RequestManager.shared.paginate(url: url)
                .flatMap { response in
                    var combinedResults = self.currentState.fetchedLaunches
                    for launch in response.results {
                        if !combinedResults.contains(launch) {
                            combinedResults.append(launch)
                        }
                    }
                    
                    let stateMutation = Mutation.didUpdatefetchingState(.success(response.results))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(combinedResults)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdatefetchingState(.error(error as? AppError ?? .unknown)))
                },
            
            Observable.just(Mutation.didUpdateIsPaginating(false))
        ])
    }
}


extension Publisher {
    func asObservable() -> Observable<Output> {
        Observable.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        observer.onError(error)
                    } else {
                        observer.onCompleted()
                    }
                },
                receiveValue: {
                    observer.onNext($0)
                }
            )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }

    }
}
