//
//  TabBarView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import SwiftUIReactorKit

struct TabBarView: ReactorView {
    
    var homeReactor: HomeViewViewModel
    var launchesReactor: LaunchesViewModel
    var mapReactor: InteractiveMapViewViewModel
    var reactor: TabBarViewModel
    
    init() {
        self.homeReactor = HomeViewViewModel()
        self.launchesReactor = LaunchesViewModel(initialState: .init(fetchingState: .idle))
        self.mapReactor = InteractiveMapViewViewModel()
        self.reactor = TabBarViewModel(launchesReactor: self.launchesReactor, mapReactor: self.mapReactor)
    }
    
    func body(reactor: TabBarViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveLaunchNotification)) { _ in
                reactor.action.onNext(.setSelectedTab(TabBarViewModel.Tab.home))
            }
    }
    
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

#Preview {
    TabBarView()
}

