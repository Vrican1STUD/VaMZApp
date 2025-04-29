//
//  LaunchesView.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI

struct LaunchesView: View {
    
    @ObservedObject var viewModel = LaunchesViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.fetchingState {
            case .idle:
                EmptyView()
                
            case .loading:
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tint(.Text.primary)
                
            case .success:
                content(viewModel.launches)

            case .error(let error):
                errorView(error: error)
            }
        }
        .background(Color.App.background)
        .task {
            guard !viewModel.fetchingState.isSuccess else { return }
            await viewModel.fetchLaunches(isPullToRefresh: false)
        }
    }
    
    func content(_ launches: [LaunchResult]) -> some View {
        VStack {
            Picker("Launch Type", selection: $viewModel.pickerMode) {
                ForEach(LaunchesViewModel.LauchPickerMode.allCases) { mode in
                    Text(mode.description).tag(mode.id)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            if launches.isEmpty {
                emptyView
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(launches) { launch in
                            // It doesn't need viewmodel because it is just small view that decreases repeating of the code
                            LaunchListView(
                                launch: launch,
                                isSaved: viewModel.savedLaunches.contains(launch),
                                onTap: { viewModel.selectedLaunchId = launch.id },
                                onSave: { CacheManager.shared.toggleSavedLaunch(launch) }
                            )
                            .padding(.horizontal)
                            .onAppear {
                                if launch == launches.last {
                                    Task {
                                        await viewModel.paginate()
                                    }
                                }
                            }
                        }
                        
                        if viewModel.isPaginating {
                            ProgressView()
                        }
                    }
                    .padding(.vertical)
                }
                .scrollIndicators(.hidden)
                .refreshable { await viewModel.fetchLaunches(isPullToRefresh: true) }
                .scrollContentBackground(.hidden)
                .navigationDestination(item: $viewModel.selectedLaunchId) { id in
                    //TODO: chnge to viewmodel
                    if let launchWithDetail = launches.first(where: { $0.id == id }) {
                        LaunchDetailView(isSaved: CacheManager.shared.savedLaunches.contains(launchWithDetail),
                                         id: id,
                                         onSave: { CacheManager.shared.toggleSavedLaunch(launchWithDetail)})
                    }
                }
            }
        }
        .onReceive(CacheManager.shared.savedLaunchedPublisher) {
            viewModel.savedLaunches = $0
        }
    }
    
    @ViewBuilder
    var emptyView: some View {
        VStack {
            Spacer()
            Image(.astronaut)
            
            switch viewModel.pickerMode {
            case .all:
                Text("No available launches")
            case .saved:
                Text("No saved Launches")
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
    }
    
    func errorView(error: AppError) -> some View {
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
                Task { Task { await viewModel.fetchLaunches(isPullToRefresh: false) } }
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
