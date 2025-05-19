//
//  NavigationManager.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import Foundation
import Combine

// MARK: - Navigation Manager

/// A singleton responsible for handling global navigation events using Combine.
///
/// It uses a `PassthroughSubject` to publish navigation targets that can be
/// observed elsewhere in the app (e.g. Coordinators or ViewModels).
final class NavigationManager {
    
    /// Shared singleton instance.
    static let shared = NavigationManager()
    
    private init() {}
    
    /// A type-erased publisher that emits navigation targets.
    private let navigationSubject = PassthroughSubject<NavigationTarget, Never>()
    var navigationPublisher: AnyPublisher<NavigationTarget, Never> {
        navigationSubject.eraseToAnyPublisher()
    }
    
    /// Emits a navigation event to a specific launch detail screen.
    func navigateTo(_ launch: LaunchResult) {
        navigationSubject.send(.launch(launch))
    }
    
    /// Emits a navigation event to the map view, focusing on a specific location./
    func navigateToMapAndShow(_ mapPointLocation: MapPointLocation) {
        navigationSubject.send(.map(mapPointLocation))
    }
}

// MARK: - Navigation Target Enum

/// Represents high-level navigation destinations in the app.
enum NavigationTarget {
    case launch(LaunchResult)
    case map(MapPointLocation)
}
