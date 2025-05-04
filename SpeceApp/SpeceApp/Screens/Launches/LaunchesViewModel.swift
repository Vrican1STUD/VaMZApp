//
//  LaunchesViewModel.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import SwiftUI

@MainActor
final class LaunchesViewModel: ObservableObject {

    enum LauchPickerMode: CaseIterable, Identifiable, CustomStringConvertible {
        case all
        case saved
        
        var id: Self { self }

        var description: String {
            switch self {
            case .all: "All"
            case .saved: "Saved"
            }
        }
    }
    
    @Published var fetchingState: FetchingState<[LaunchResult], AppError> = .idle
    @Published var pickerMode: LauchPickerMode = .all
    
    @Published var fetchedLaunches: [LaunchResult] = []
    @Published var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
    
    @Published var selectedLaunchId: String?
    
    @Published var paginatingUrl: URL?
    @Published var isPaginating = false
    
    var launches: [LaunchResult] {
        switch pickerMode {
        case .all:
            fetchedLaunches
        case .saved:
            fetchedLaunches.filter({ CacheManager.shared.savedLaunches.contains($0) })
        }
    }
}

// MARK: - Public

extension LaunchesViewModel {
    
    func fetchLaunches(isPullToRefresh: Bool) async {
        if isPullToRefresh {
            try? await Task.sleep(for: .seconds(0.5))
        } else {
            fetchingState = .loading
        }
        
        var result: FetchingState<[LaunchResult], AppError>
        
        do {
            let response = try await RequestManager.shared.fetchUpcomingLaunches()
            paginatingUrl = response.nextPagingUrl

            result = .success(response.results)
        } catch {
            print(error.asAFError?.underlyingError?.localizedDescription)
            result = .error(error as? AppError ?? .unknown)
        }
        
        if isPullToRefresh {
            try? await Task.sleep(for: .seconds(0.5))
        }
        fetchingState = result
        
        if let launches = result.successValue, !isPullToRefresh {
            for launch in launches {
                if !fetchedLaunches.contains(launch) {
                    fetchedLaunches.append(launch)
                }
            }
        } else {
            fetchedLaunches = fetchingState.successValue ?? []
        }
    }
    
    func paginate() async {
        guard let paginatingUrl else { return }
        
        isPaginating = true
        do {
            let response = try await RequestManager.shared.paginate(url: paginatingUrl)
            self.paginatingUrl = response.nextPagingUrl
            
            for launch in response.results {
                if !fetchedLaunches.contains(launch) {
                    fetchedLaunches.append(launch)
                }
            }
        } catch {
            
        }
        isPaginating = false
    }
    
}

import ReactorKit
import Combine

final class LaunchesViewModel2: Reactor {
    
    typealias LaunchesState = FetchingState<[LaunchResult], AppError>
    
    enum LaunchPickerMode: CaseIterable, Identifiable, CustomStringConvertible {
        case all
        case saved
        
        var id: Self { self }

        var description: String {
            switch self {
            case .all: "All"
            case .saved: "Saved"
            }
        }
    }
    
    enum Action {
        case fetchLaunches(isPullToRefresh: Bool)
        case paginate
        
        case setPickerMode(LaunchPickerMode)
    }
    
    enum Mutation {
        case didUpdatefetchingState(LaunchesState)
        case didUpdateIsPaginating(Bool)
        case didUpdatePaginatingURL(URL?)
        
        case didSetPickerMode(LaunchPickerMode) //set or update
        case didUpdateFetchedLaunches([LaunchResult])
    }
    
    struct State {
        var fetchingState: LaunchesState = .idle
        var paginatingUrl: URL?
        var isPaginating = false
        
        var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
        
        var fetchedLaunches: [LaunchResult] = []
        var pickerMode: LaunchPickerMode = .all
        var launches: [LaunchResult] {
            switch pickerMode {
            case .all:
                fetchedLaunches
            case .saved:
                fetchedLaunches.filter({ CacheManager.shared.savedLaunches.contains($0) })
            }
        }
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunches(let isPullToRefresh):
            return fetchLaunches(isPullToRefresh: isPullToRefresh)
        case .paginate:
            return paginate()
        case .setPickerMode(let mode):
            return .just(.didSetPickerMode(mode))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdatefetchingState(let fetchingState):
            state.fetchingState = fetchingState
        case .didUpdateIsPaginating(let isPaginating):
            state.isPaginating = isPaginating
        case .didUpdatePaginatingURL(let paginatingURL):
            state.paginatingUrl = paginatingURL
            
        case .didSetPickerMode(let mode):
            state.pickerMode = mode
        case .didUpdateFetchedLaunches(let fetchedLaunches):
            state.fetchedLaunches = fetchedLaunches
        }
        
        return state
    }
    
    func fetchLaunches(isPullToRefresh: Bool) -> Observable<Mutation> {
        let delayDuration = isPullToRefresh ? 1.8 : 0.0
        
        return Observable.concat([
            Observable<Void>.just(())
                .delay(.milliseconds(Int(delayDuration * 1000)), scheduler: MainScheduler.instance)
                .map { Mutation.didUpdatefetchingState(.loading) },
            
            RequestManager.shared.fetchLaunches2()
                .flatMap { response -> Observable<Mutation> in
                    let stateMutation = Mutation.didUpdatefetchingState(.success(response.results))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(response.results)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdatefetchingState(.error(error as? AppError ?? .unknown)))
                }
        ])
    }
    
    func paginate() -> Observable<Mutation> {
        guard let url = currentState.paginatingUrl else {
            return .empty() // No more pages to load
        }
        
        return Observable.concat([
            Observable.just(Mutation.didUpdateIsPaginating(true)),
            
            RequestManager.shared.paginate2(url: url)
                .flatMap { response in
                    var combinedResults = self.currentState.fetchedLaunches
                    for launch in response.results {
                        if !combinedResults.contains(launch) {
                            combinedResults.append(launch)
                        }
                    }
                    
                    let stateMutation = Mutation.didUpdatefetchingState(.success(response.results))
                    let launchesMutation = Mutation.didUpdateFetchedLaunches(combinedResults)
                    let urlMutation = Mutation.didUpdatePaginatingURL(response.nextPagingUrl)
                    
                    return Observable.from([stateMutation, launchesMutation, urlMutation])
                }
                .catch { error in
                    Observable.just(Mutation.didUpdatefetchingState(.error(error as? AppError ?? .unknown)))
                },
            
            Observable.just(Mutation.didUpdateIsPaginating(false))
        ])
    }
}

import SwiftUIReactorKit

struct LaunchesView2: ReactorView {
    
    var reactor: LaunchesViewModel2 = .init(initialState: .init(fetchingState: .idle))
    
    func body(reactor: LaunchesViewModel2.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state)
    }
    
    @ViewBuilder
    func content(state: LaunchesViewModel2.State) -> some SwiftUI.View {
        switch state.fetchingState {
        case .loading:
            ProgressView()
                .controlSize(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tint(.Text.primary)
        case .idle:
            //EmptyView is not working, so I had to use Text
            Text("")
                .onAppear { reactor.action.onNext(.fetchLaunches(isPullToRefresh: false)) }
        case .success(let response):
            VStack {
                Picker("Launch Type", selection: Binding(
                    get: { state.pickerMode },
                    set: { newValue in reactor.action.onNext(.setPickerMode(newValue)) }
                )) {
                    ForEach(LaunchesViewModel2.LaunchPickerMode.allCases) { mode in
                        Text(mode.description).tag(mode.id)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if state.launches.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(state.launches) { launch in
                                // It doesn't need viewmodel because it is just small view that decreases repeating of the code
                                LaunchListView(
                                    launch: launch,
                                    isSaved: CacheManager.shared.savedLaunches.contains(launch),
                                    onTap: {},
                                    onSave: { CacheManager.shared.toggleSavedLaunch(launch) }
                                )
                                .padding(.horizontal)
                                .onAppear {
                                    if launch == state.launches.last {
                                        reactor.action.onNext(.paginate)
                                    }
                                }
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
            }
//            .onReceive(CacheManager.shared.savedLaunchedPublisher) {
//                viewModel.savedLaunches = $0
//            }
        case .error(let error):
            errorView(error: error)
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
//                Task { Task { await viewModel.fetchLaunches(isPullToRefresh: false) } }
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
