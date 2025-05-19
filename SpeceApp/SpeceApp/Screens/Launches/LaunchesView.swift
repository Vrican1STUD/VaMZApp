//
//  LaunchesView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI
import SwiftUIReactorKit

struct LaunchesView: ReactorView {
    
    @State private var searchText: String = ""
    
    var reactor: LaunchesViewModel
    
    // MARK: - View body
    
    func body(reactor: LaunchesViewModel.ObservableObject) -> some View {
        content(state: reactor.state)
    }
    
    // MARK: - Main content builder
    
    @ViewBuilder
    func content(state: LaunchesViewModel.State) -> some View {
        VStack {
            // Picker to select between all launches or saved launches
            Picker(
                String(localized: "list.type"),
                selection: reactor.binding(for: \.pickerMode, set: { .setPickerMode($0) })
            ) {
                ForEach(LaunchesViewModel.LaunchPickerMode.allCases) { mode in
                    Text(mode.description).tag(mode.id)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Show appropriate content based on picker mode
            switch state.pickerMode {
            case .all:
                handleLoadingOfLaunches(state: state)
            case .saved:
                if state.filteredSavedLaunches.isEmpty {
                    EmptyLaunchesView(description: String(localized: "list.saved.empty"))
                } else {
                    ScrollView {
                        LazyVStack {
                            fillLaunchesList(launches: state.filteredSavedLaunches, reactor: reactor)
                        }
                        .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { newValue in
            reactor.action.onNext(.setSearchText(newValue))
        }
        // Navigate to detail view when a launch is selected
        .navigationDestination(
            item: reactor.binding(for: \.selectedLaunch, set: {.setSelectedLaunch($0)}),
            destination: { launch in
                LaunchDetailView(reactor: .init(launch: launch))
            }
        )
    }
    
    // MARK: - Handle loading / error / success states for all launches
    
    @ViewBuilder
    func handleLoadingOfLaunches(state: LaunchesViewModel.State) -> some View {
        switch state.fetchingState {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.Text.primary)
        case .idle:
            EmptyView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(_):
            if state.fetchedLaunches.isEmpty {
                EmptyLaunchesView(description: String(localized: "list.available.empty"))
            } else {
                ScrollView {
                    LazyVStack {
                        addTestLaunch()
                        fillLaunchesList(launches: state.fetchedLaunches, reactor: reactor)
                        Color.clear
                            .frame(height: 1)
                            .onAppear {
                                reactor.action.onNext(.paginate)
                            }
                        if state.isPaginating {
                            ProgressView()
                        }
                    }
                    .padding(.vertical)
                }
                .scrollIndicators(.hidden)
                .refreshable { reactor.action.onNext(.fetchLaunches(isPullToRefresh: true)) }
                .scrollContentBackground(.hidden)
            }
        case .error(let error):
            LaunchErrorView(error: error, onRetry: { reactor.action.onNext(.fetchLaunches(isPullToRefresh: true)) })
        }
    }
    
    // MARK: - Populate list with launches
    
    @ViewBuilder
    func fillLaunchesList(launches: [LaunchResult], reactor: LaunchesViewModel) -> some View {
        ForEach(launches) { launch in
            LaunchListView(
                launch: launch,
                isSaved: reactor.currentState.savedLaunches.contains(launch),
                onTap: { reactor.action.onNext(.setSelectedLaunch(launch)) },
                onSave: { reactor.action.onNext(.toggleLaunch(launch)) }
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Add a test launch item (for development/debugging)
    
    @ViewBuilder
    func addTestLaunch() -> some View {
        let launch = LaunchResult.mock(name: "TestLaunch", offset: 180)
        LaunchListView(
            launch: launch,
            isSaved: reactor.currentState.savedLaunches.contains(launch),
            onTap: { reactor.action.onNext(.setSelectedLaunch(launch)) },
            onSave: { reactor.action.onNext(.toggleLaunch(launch)) }
        )
        .padding(.horizontal)
    }
}
