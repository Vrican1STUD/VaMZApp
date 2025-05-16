//
//  TabBarViewModel.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit

final class TabBarViewModel: Reactor {
    
    enum Action {
        case updateSelectedTab(Tab)
        case openLaunch(LaunchResult)
        case ShowOnMap(MapPointLocation)
    }
    
    enum Mutation {
        case didUpdateSelectedTab(Tab)
    }
    
    struct State {
        var selectedTab: Tab = .home
    }
    
    var initialState: State
    private let launchesReactor: LaunchesViewModel
    private let mapReactor: InteractiveMapViewViewModel
    
    enum Tab: Int, Hashable {
        case home
        case launches
        case map
    }
    
    init(launchesReactor: LaunchesViewModel, mapReactor: InteractiveMapViewViewModel) {
        self.initialState = State()
        self.launchesReactor = launchesReactor
        self.mapReactor = mapReactor
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        let navigationStream = CacheManager.shared.navigationPublisher
            .asObservable()
            .compactMap { target -> Action? in
                switch target {
                case .launch(let launch):
                    return .openLaunch(launch)
                case .map(let mapPointLocation):
                    return .ShowOnMap(mapPointLocation)
                }
            }
        return Observable.merge(
            action,
            navigationStream
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateSelectedTab(let tab):
            return .just(.didUpdateSelectedTab(tab))
        case .openLaunch(let launch):
            // Navigate to the Launches tab
            let changeTab = Observable.just(Mutation.didUpdateSelectedTab(.launches))
            
            // Set pickerMode to `.saved` via its own Reactor
            let updateLaunches = Observable.just(()).delay(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: { [weak self] _ in
                    self?.launchesReactor.action.onNext(.setPickerMode(.saved))
                    self?.launchesReactor.action.onNext(.setSelectedLaunch(launch))
                })
                .flatMap { _ in Observable<Mutation>.empty() }
            
            return Observable.concat([changeTab, updateLaunches])
        case .ShowOnMap(let mapPointLocation):
            let changeTab = Observable.just(Mutation.didUpdateSelectedTab(.map))
            let sendToMapView = Observable.just(())
                .delay(.milliseconds(300), scheduler: MainScheduler.instance)
                .do(onNext: { [weak self] in
                    self?.mapReactor.action.onNext(.setActualLocation(mapPointLocation))
                })
                .flatMap { Observable<Mutation>.empty() }

            return Observable.concat([changeTab, sendToMapView])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateSelectedTab(let tab):
            state.selectedTab = tab
        }
        
        return state
    }
    
}

