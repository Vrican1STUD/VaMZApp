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
    
    @CachedValue("savedLaunches") var savedLaunches: [LaunchResult] = []
    private(set) lazy var savedLaunchesPublisher = $savedLaunches.share().eraseToAnyPublisher()
    
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
}
