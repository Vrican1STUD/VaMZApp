//
//  CacheManager.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import Foundation
import Combine

final class CacheManager {
    
    static let shared = CacheManager()
    
    private init() {}
    
    let navigationSubject = PassthroughSubject<NavigationTarget, Never>()
    private(set) lazy var navigationPublisher = navigationSubject.eraseToAnyPublisher()
    
    @CachedValue("savedLaunches") var savedLaunches: [LaunchResult] = []
    private(set) lazy var savedLaunchedPublisher = $savedLaunches.share().eraseToAnyPublisher()
    
    func toggleSavedLaunch(_ launch: LaunchResult) {
        if savedLaunches.contains(launch) {
            savedLaunches.removeAll { $0 == launch }
        } else {
            savedLaunches.append(launch)
        }
    }
    
    func removeSavedLaunches() {
        savedLaunches = []
    }
    
    func navigateTo(_ launch: LaunchResult) {
        navigationSubject.send(.launch(launch))
    }
    
    func navigateToMapAndShow(_ mapPointLocation: MapPointLocation) {
        navigationSubject.send(.map(mapPointLocation))
    }
}

enum NavigationTarget {
    case launch(LaunchResult)
    case map(MapPointLocation)
}

