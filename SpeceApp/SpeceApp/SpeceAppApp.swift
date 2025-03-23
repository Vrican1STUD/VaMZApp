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
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
    
}
