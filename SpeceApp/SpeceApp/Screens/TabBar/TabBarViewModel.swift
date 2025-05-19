//
//  TabBarViewModel.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit

// MARK: - TabBarViewModel

/// Reactor managing the state and navigation logic of the Tab Bar in the app.
final class TabBarViewModel: Reactor {
    
    // MARK: Tab Enum
    
    enum Tab: Int, Hashable {
        case home
        case launches
        case map
    }
    
    // MARK: Actions
    
    enum Action {
        case setSelectedTab(Tab)
        case navigateAndOpenLaunch(LaunchResult)
        case navigateAndShowOnMap(MapPointLocation)
    }
    
    // MARK: Mutations
    
    enum Mutation {
        case didUpdateSelectedTab(Tab)
    }
    
    // MARK: State
    
    struct State {
        var selectedTab: Tab = .home
    }
    
    // MARK: Properties
    
    var initialState: State
    private let launchesReactor: LaunchesViewModel
    private let mapReactor: InteractiveMapViewViewModel
    
    // MARK: Initialization
    
    init(launchesReactor: LaunchesViewModel, mapReactor: InteractiveMapViewViewModel) {
        self.initialState = State()
        self.launchesReactor = launchesReactor
        self.mapReactor = mapReactor
    }
    
    // MARK: Transform
    
    /// Combines incoming actions with navigation events into a single stream of actions.
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
    
    // MARK: Mutate
    
    /// Processes incoming actions into mutations.
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
    
    // MARK: Reduce
    
    /// Applies mutations to current state producing a new state.
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateSelectedTab(let tab):
            state.selectedTab = tab
        }
        
        return state
    }
    
    // MARK: Navigation Helpers
    
    /// Switches to the Launches tab and selects a specific launch after a slight delay.
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
    
    /// Switches to the Map tab and sets the actual location on the map after a slight delay.
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
