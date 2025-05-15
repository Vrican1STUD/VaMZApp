//
//  TabBarView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI

struct TabBarView: View {
    
    var launchesReactor: LaunchesViewModel
    
    init() {
        self.launchesReactor = LaunchesViewModel(initialState: .init(fetchingState: .idle))
    }
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            NavigationStack {
                LaunchesView(reactor: launchesReactor)
                    .navigationTitle("Launches")
            }
            .tabItem { Label("Launches", systemImage: "paperplane.fill") }
            
            InteractiveMapView()
                .tabItem { Label("Launch", systemImage: "magnifyingglass") }
        }
    }
}
