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
    
    enum Tab: Int, Hashable {
        case home
        case launches
        case map
    }
    
    enum Action {
        case setSelectedTab(Tab)
        case navigateAndOpenLaunch(LaunchResult)
        case navigateAndShowOnMap(MapPointLocation)
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
    
    init(launchesReactor: LaunchesViewModel, mapReactor: InteractiveMapViewViewModel) {
        self.initialState = State()
        self.launchesReactor = launchesReactor
        self.mapReactor = mapReactor
    }
    
    func transform(action: Observable<Action>) -> Observable<Action> {
        let navigationStream = NavigationManager.shared.navigationPublisher
            .asObservable()
            .compactMap { target -> Action? in
                switch target {
                case .launch(let launch):
                    return .navigateAndOpenLaunch(launch)
                case .map(let mapPointLocation):
                    return .navigateAndShowOnMap(mapPointLocation)
                }
            }
        return Observable.merge(
            action,
            navigationStream
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setSelectedTab(let tab):
            return .just(.didUpdateSelectedTab(tab))
        case .navigateAndOpenLaunch(let launch):
            return openLaunchAndMoveToSaved(launch: launch)
        case .navigateAndShowOnMap(let mapPointLocation):
            return showPointOnMap(mapPointLocation: mapPointLocation)
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
    
    func openLaunchAndMoveToSaved(launch: LaunchResult) -> Observable<Mutation> {
        let changeTab = Observable.just(Mutation.didUpdateSelectedTab(.launches))
        
        let updateLaunches = Observable.just(()).delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.launchesReactor.action.onNext(.setPickerMode(.saved))
                self?.launchesReactor.action.onNext(.setSelectedLaunch(launch))
            })
            .flatMap { _ in Observable<Mutation>.empty() }
        
        return Observable.concat([changeTab, updateLaunches])
    }
    
    func showPointOnMap(mapPointLocation: MapPointLocation) -> Observable<Mutation> {
        let changeTab = Observable.just(Mutation.didUpdateSelectedTab(.map))
        let sendToMapView = Observable.just(())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance) // Delay to wait for tab transition animation
            .do(onNext: { [weak self] in
                self?.mapReactor.action.onNext(.setActualLocation(mapPointLocation))
            })
            .flatMap { Observable<Mutation>.empty() }

        return Observable.concat([changeTab, sendToMapView])
    }
}
