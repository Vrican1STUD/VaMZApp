//
//  LaunchesView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI

//Problems: TODOs, Dependency injection, Tide up

import SwiftUIReactorKit

struct LaunchesView: ReactorView {
    
    @State var searchQuery: String = ""
    
    var reactor: LaunchesViewModel
    
    func body(reactor: LaunchesViewModel.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: LaunchesViewModel.State) -> some SwiftUI.View {
        VStack {
            // TODO: Strange picker bug
            Picker("Launch Type", selection: reactor.binding(for: \.pickerMode, set: { .setPickerMode($0) })) {
                ForEach(LaunchesViewModel.LaunchPickerMode.allCases) { mode in
                    Text(mode.description).tag(mode.id)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            switch state.pickerMode {
            case .all:
                handleLoadingOfLaunches(state: state)
            case .saved:
                if state.savedLaunches.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack {
                            fillLaunchesList(launches: state.savedLaunches, reactor: reactor)
                        }
                        .padding(.vertical)
                    }
                    .scrollIndicators(.hidden)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationDestination(item: reactor.binding(for: \.selectedLaunch, set: {.setSelectedLaunch($0)}), destination: {launch in
            LaunchDetailView(reactor: .init(launch: launch))
        })
    }
    
    @ViewBuilder
    func handleLoadingOfLaunches( state: LaunchesViewModel.State ) -> some SwiftUI.View {
        switch state.fetchingState {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.Text.primary)
        case .idle:
            //EmptyView is not working, so I had to use Text
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .success(_):
            if state.fetchedLaunches.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack {
                        let launch = LaunchResult(id: "7b685ef7-f610-413f-bd4a-cc58aed97be2", url: "", name: "TestLaunch", slug: "", lastUpdated: "", net: Date().addingTimeInterval(30).ISO8601Format().uppercased(), windowEnd: "", windowStart: "", image: LaunchImage(imageUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png",
                            thumbnailUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png"))
                        LaunchListView(
                            launch: launch,
                            isSaved: CacheManager.shared.savedLaunches.contains(launch),
                            onTap: { reactor.action.onNext(.setSelectedLaunch(launch)) },
                            onSave: {
                                CacheManager.shared.toggleSavedLaunch(launch)
                                NotificationManager.shared.toggleLaunchNotification(launch: launch)
                            }
                        )
                        .padding(.horizontal)
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
            errorView(error: error)
        }
    }
    
    func fillLaunchesList( launches: [LaunchResult], reactor: LaunchesViewModel ) -> some SwiftUI.View {
        ForEach(launches) { launch in
            LaunchListView(
                launch: launch,
                isSaved: CacheManager.shared.savedLaunches.contains(launch),
                onTap: { reactor.action.onNext(.setSelectedLaunch(launch)) },
                onSave: {
                    CacheManager.shared.toggleSavedLaunch(launch)
                    NotificationManager.shared.toggleLaunchNotification(launch: launch)
                }
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    var emptyView: some SwiftUI.View {
        VStack {
            Spacer()
            Image(.astronaut)
            
            switch reactor.currentState.pickerMode {
            case .all:
                Text("No available launches")
            case .saved:
                Text("No saved Launches")
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    
    func errorView(error: AppError) -> some SwiftUI.View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(.astronaut)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 32)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
            
            Button {
                reactor.action.onNext(.fetchLaunches(isPullToRefresh: true))
            } label: {
                Text("Retry")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 60)
                    .background(Color.App.Button.normal)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.scaled)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
