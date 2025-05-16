//
//  TabBarView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import SwiftUIReactorKit

struct TabBarView: ReactorView {
    
    var launchesReactor: LaunchesViewModel
    var mapReactor: InteractiveMapViewViewModel
    var reactor: TabBarViewModel
    
    init() {
        self.launchesReactor = LaunchesViewModel(initialState: .init(fetchingState: .idle))
        self.mapReactor = InteractiveMapViewViewModel()
        self.reactor = TabBarViewModel(launchesReactor: self.launchesReactor, mapReactor: self.mapReactor)
    }
    
    func body(reactor: TabBarViewModel.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: TabBarViewModel.State) -> some SwiftUI.View {
        TabView(selection: reactor.binding(for: \.selectedTab, set: { .updateSelectedTab($0) })) {
            HomeView(reactor: HomeViewViewModel())
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(TabBarViewModel.Tab.home)
            
            NavigationStack {
                LaunchesView(reactor: launchesReactor)
                    .navigationTitle("Launches")
            }
            .tabItem { Label("Launches", systemImage: "paperplane.fill") }
            .tag(TabBarViewModel.Tab.launches)
            
            InteractiveMapView(reactor: mapReactor)
                .tabItem { Label("Map", systemImage: "map") }
                .tag(TabBarViewModel.Tab.map)
        }
    }
}

#Preview {
    TabBarView()
}
