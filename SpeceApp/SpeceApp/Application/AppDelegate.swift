//
//  AppDelegate.swift
//  SpeceApp
//
//  Created by Peter on 12/03/2025.
//

import SwiftUI

/// The main entry point of the application.
@main
struct AppDelegate: App {
    
    init() {
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .tint(.Text.primary)
        }
    }
}
