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
    
    //private let network: LaunchFetcher = .init()
    
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
    
    enum Action {
        case fetchLaunches
    }
    
    enum Mutation {
        case didUpdatefetchingState(LaunchesState)
    }
    
    struct State {
        var fetchingState: LaunchesState = .idle
    }
    
    var initialState: State
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchLaunches:
            return fetchLaunches()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdatefetchingState(let fetchingState):
            state.fetchingState = fetchingState
        }
        
        return state
    }
    
    func fetchLaunches() -> Observable<Mutation> {
        Observable.concat([
            .just(.didUpdatefetchingState(.loading)),
            RequestManager.shared.fetchLaunches2()
                .map { Mutation.didUpdatefetchingState(.success($0.results)) }
                .catch { .just(Mutation.didUpdatefetchingState(.error($0 as? AppError ?? .unknown))) }
        ])
    }
    
}

import SwiftUIReactorKit

struct LaunchesView2: ReactorView {
    
    var reactor: LaunchesViewModel2 = .init(initialState: .init(fetchingState: .idle))
    
    func body(reactor: LaunchesViewModel2.ObservableObject) -> some SwiftUI.View {
        content(state: reactor.state.fetchingState)
    }
    
    @ViewBuilder
    func content(state: LaunchesViewModel2.LaunchesState) -> some SwiftUI.View {
        switch state {
        case .loading:
            ProgressView()
        case .idle:
            Text("")
                .onAppear { reactor.action.onNext(.fetchLaunches) }
        case .success(let response):
            Text(response.map { $0.name }.joined(separator: "\n\n") )
        case .error(_):
            Text("")
        }
    }
}
