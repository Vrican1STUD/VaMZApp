//
//  CacheManager.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import Foundation
import Combine

// MARK: - Cache Manager

/// Handles caching and persistence of saved launches.
final class CacheManager {
    
    /// Shared singleton instance.
    static let shared = CacheManager()
    
    private init() {}
    
    // MARK: - Cached Properties
    
    /// Launches that have been saved by the user.
    @CachedValue("savedLaunches") var savedLaunches: [LaunchResult] = []
    
    /// A publisher that emits saved launch updates.
    private(set) lazy var savedLaunchesPublisher = $savedLaunches.share().eraseToAnyPublisher()
    
    // MARK: - API
    
    /// Adds or removes a launch from the saved list.
    /// - Parameter launch: The launch to toggle.
    func toggleSavedLaunch(_ launch: LaunchResult) {
        if savedLaunches.contains(launch) {
            savedLaunches.removeAll { $0 == launch }
        } else {
            savedLaunches.append(launch)
        }
    }
    
    /// Clears all saved launches.
    func removeSavedLaunches() {
        savedLaunches = []
    }
}
