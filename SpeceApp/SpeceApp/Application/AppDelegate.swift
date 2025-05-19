//
//  AppDelegate.swift
//  SpeceApp
//
//  Created by Peter on 12/03/2025.
//

import SwiftUI

@main
struct AppDelegate: App {
    
    init() {
        UINavigationBar.setAppearance()
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .tint(.Text.primary)
        }
    }
}
