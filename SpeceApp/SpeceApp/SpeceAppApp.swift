//
//  SpeceAppApp.swift
//  SpeceApp
//
//  Created by Peter on 12/03/2025.
//

import SwiftUI

@main
struct SpeceAppApp: App {
    
    init() {
//        UITabBar.setTabBarAppearance()
        UINavigationBar.setAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .tint(.Text.primary)
        }
    }
    
}
