//
//  LaunchDetailViewModel.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import Foundation

import SwiftUI
import Combine

@MainActor
final class LaunchDetailViewModel: ObservableObject {
    
    @Published var fetchingState: FetchingState<LaunchDetailResult, AppError> = .idle
    @Published var days: Int = 0
    @Published var hours: Int = 0
    @Published var minutes: Int = 0
    
    @Published var now: Date = Date()
    private var timer: Timer?
    
    private var tasks: [Task<Void, Never>] = []
    private var cancellables: Set<AnyCancellable> = .init()
    
    var countdownText: String {
        let calendar = Calendar.current
        
        let timeComponens: [Calendar.Component] =
        [
            .year, .month, .day, .hour, .minute, .second
        ]
        
        return timeComponens
            .map { component -> String in
            "\(calendar.component(component, from: now))"
        }
        .joined(separator: " : ")

    }
    
    //    @Published var fetchedDetail: LaunchDetailResult = []
    //    @Published var savedLaunches: [LaunchResult] = CacheManager.shared.savedLaunches
}

// MARK: - Public

extension LaunchDetailViewModel {
    
    func startTimer() {
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()
            .sink(receiveValue: { [weak self] _ in
                guard let self else { return }
                now.addTimeInterval(-1)
            })
            .store(in: &cancellables)
    }
    
    func fetchData(id: String) {
        fetchingState = .loading
        cancellables.removeAll()
        RequestManager.shared.fetchLaunchDetail(id: id)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.fetchingState = .error(error)
                }
            }, receiveValue: { [weak self] in
                self?.fetchingState = .success($0)
                self?.now = $0.netDate ?? .now
                self?.startTimer()
            })
            .store(in: &cancellables)
    }
    
    func fetchDetail(isPullToRefresh: Bool, id: String) {
        let fetchingTask = Task { [weak self] in
            guard let self else { return }
            
            if isPullToRefresh {
                try? await Task.sleep(for: .seconds(0.5))
            } else {
                fetchingState = .loading
            }
            
            var result: FetchingState<LaunchDetailResult, AppError>
            
            do {
                let response = try await RequestManager.shared.fetchDetailOfLaunch(id: id)
                result = .success(response)
                
                //            self.now = Date()
                //            if let launchDate = response.netDate {
                //                let components = Calendar.current.dateComponents([.day, .hour, .minute], from: self.now, to: launchDate)
                //                self.days = components.day ?? 0
                //                self.hours = components.hour ?? 0
                //                self.minutes = components.minute ?? 0
                //            }
                //
                //            let calendar = Calendar.current
                //            let nextMinute = calendar.nextDate(after: now, matching: DateComponents(second: 0), matchingPolicy: .strict)!
                //            let delay = nextMinute.timeIntervalSince(now)
                
                //            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                //                self?.startRepeatingTimer()
                //            }
                //
            } catch {
                print(error.asAFError?.underlyingError?.localizedDescription)
                result = .error(error as? AppError ?? .unknown)
            }
            
            fetchingState = result
        }
        
        tasks.append(fetchingTask)
    }
    
    func deleteTasks() {
        tasks.forEach { $0.cancel() }
        tasks = []
    }
    
//    func startRepeatingTimer() {
//        self.now = Date() // Fire once immediately
//        
//        
//        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
//            if let me = self {
//                me.now = Date()
//                switch me.fetchingState {
//                case .success:
//                    if let launchDate = me.fetchingState.successValue?.netDate {
//                        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: me.now, to: launchDate)
//                        me.days = components.day ?? 0
//                        me.hours = components.hour ?? 0
//                        me.minutes = components.minute ?? 0
//                        print(launchDate)
//                        print(me.now)
//                    }
//                case .loading:
//                    print("")
//                case .idle:
//                    print("")
//                case .error(_):
//                    print("")
//                }
//            }
//            
//            
//        }
//    }
}

