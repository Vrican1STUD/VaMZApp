//
//  NavigationManager.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import Foundation
import Combine

final class NavigationManager {
    
    static let shared = NavigationManager()
    private init() {}
    
    private let navigationSubject = PassthroughSubject<NavigationTarget, Never>()
    var navigationPublisher: AnyPublisher<NavigationTarget, Never> {
        navigationSubject.eraseToAnyPublisher()
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
