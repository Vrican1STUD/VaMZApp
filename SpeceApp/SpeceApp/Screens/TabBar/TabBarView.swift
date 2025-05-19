//
//  TabBarView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import SwiftUIReactorKit

// MARK: - TabBar View

/// Main tab bar view managing the Home, Launches, and Map tabs with their respective reactors
struct TabBarView: ReactorView {
    
    // MARK: Properties
    
    var homeReactor: HomeViewViewModel
    var launchesReactor: LaunchesViewModel
    var mapReactor: InteractiveMapViewViewModel
    var reactor: TabBarViewModel
    
    // MARK: Initialization
    
    init() {
        self.homeReactor = HomeViewViewModel()
        self.launchesReactor = LaunchesViewModel(initialState: .init(fetchingState: .idle))
        self.mapReactor = InteractiveMapViewViewModel()
        self.reactor = TabBarViewModel(launchesReactor: self.launchesReactor, mapReactor: self.mapReactor)
    }
    
    // MARK: Body
    
    func body(reactor: TabBarViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveLaunchNotification)) { _ in
                // Switch to Home tab when a launch notification is received
                reactor.action.onNext(.setSelectedTab(TabBarViewModel.Tab.home))
            }
    }
    
    // MARK: Content View
    
    @ViewBuilder
    func content(state: TabBarViewModel.State) -> some View {
        TabView(selection: reactor.binding(for: \.selectedTab, set: { .setSelectedTab($0) })) {
            
            HomeView(reactor: homeReactor)
                .tabItem { Label(String(localized: "tabbar.home"), systemImage: "house.fill") }
                .tag(TabBarViewModel.Tab.home)
            
            NavigationStack {
                LaunchesView(reactor: launchesReactor)
                    .navigationTitle(String(localized: "tabbar.launches"))
            }
            .tabItem { Label(String(localized: "tabbar.launches"), systemImage: "paperplane.fill") }
            .tag(TabBarViewModel.Tab.launches)
            
            InteractiveMapView(reactor: mapReactor)
                .tabItem { Label(String(localized: "tabbar.map"), systemImage: "map") }
                .tag(TabBarViewModel.Tab.map)
        }
    }
}

// MARK: - Preview

#Preview {
    TabBarView()
}
