//
//  HomeView.swift
//  SpeceApp
//
//  Created by Ja on 12/03/2025.
//

import SwiftUI

struct HomeView: View {
    
    @State var isSheetPresented = false
    
    var body: some View {
        TabView {
            NavigationStack {
                LaunchesView()
                    .navigationTitle("Launches")
            }
            .tabItem { Label("Launches", systemImage: "paperplane.fill") }
            
            LaunchView()
                .tabItem { Label("Launch", systemImage: "magnifyingglass") }
        }
    }
}

#Preview {
    HomeView()
}

//struct CountdownView: View {
//    
//    @ObservedObject var viewModel: CountdownViewModel = .init()
//    
//    var filteredItems: [String] {
//        let array = (0..<100).map {"Item_\($0)"}
//        return viewModel.searchText.isEmpty ? array : array.filter { $0 == viewModel.searchText }
//    }
//    
//    
//    
//    var body: some View {
//        ScrollView {
//           
////                Button(action: {
////                    requestNotify()
////                }) {
////                    Text(NSLocalizedString("Vyziadaj", comment: ""))
////                        .padding()
////                        .frame(maxWidth: .infinity)
////                        .background(Color.blue)
////                        .foregroundColor(.white)
////                        .cornerRadius(10)
////                        .padding(.horizontal)
////                }
////                Button(action: {
////                    buttonTapped()
////                }) {
////                    Text(NSLocalizedString("Notifikacia", comment: ""))
////                        .padding()
////                        .frame(maxWidth: .infinity)
////                        .background(Color.blue)
////                        .foregroundColor(.white)
////                        .cornerRadius(10)
////                        .padding(.horizontal)
////                }
////                Button(action: {
////                    checkNotify()
////                }) {
////                    Text(NSLocalizedString("Skontroluj", comment: ""))
////                        .padding()
////                        .frame(maxWidth: .infinity)
////                        .background(Color.blue)
////                        .foregroundColor(.white)
////                        .cornerRadius(10)
////                        .padding(.horizontal)
////                }
//                switch viewModel.fetchingState {
//                case .loading:
//                    VStack {
//                        ProgressView()
//                    }
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .tint(.Text.primary)
//                
//                case .idle:
//                    Rectangle()
//                        .fill(.black)
//                
//                case .success(let launches):
//                    ForEach(launches) { launch in
//                        LaunchListView(
//                            launch: launch, 
//                            isSaved: CacheManager.shared.savedLaunches.contains(launch),
//                            onTap: {  },
//                            onSave: { CacheManager.shared.toggleSavedLaunch(launch) }
//                        )
//                        .listRowBackground(Color.clear)
//                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
//                        .listRowSeparator(.hidden)
//                        .padding(.horizontal, 16)
//                    }
//                case .error(let e):
//                    
//                    Text(e.localizedDescription)
//                }
//            
//        }
//        .onReceive(CacheManager.shared.savedLaunchedPublisher) {
//            print($0.count)
//        }
//        .listStyle(.plain)
//        .scrollContentBackground(.hidden)
//        .refreshable { viewModel.send(action: .fetchLaunches(isPullToRefresh: true)) }
//        .searchable(
//            text: viewModel.binding(for: \.searchText, action: { newValue in .changeSearchText(newValue) })
//        )
//        .onReceive(viewModel.$searchText, perform: { updatedValue in
//            print(updatedValue)
//        })
//        .background(Color.black.ignoresSafeArea())
//        .onAppear { viewModel.send(action: .fetchLaunches()) }
//        
//    }
//    
//    func requestNotify() {
//        Task {
//            let isGranted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
//            let status  = try await UNUserNotificationCenter.current().notificationSettings()
//            
//            print(
//                isGranted, status.authorizationStatus
//            )
//        }
//    }
//
//    func buttonTapped() {
//        scheduleLocalizedNotification()
//    }
//    
//    func checkNotify() {
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            print("Pending notifications: \(requests)")
//        }
//    }
//    
//    func launch(item: String) -> some View {
//        HStack {
//            Text(item)
//                .font(.body.bold())
//                .padding()
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(.gray)
//        .padding(.horizontal, 10)
//    }
//    
//}

//@MainActor
//class CountdownViewModel: MyObservableModel {
//    
//    private let network: LaunchFetcher = .init()
//    
//    func send(action: Action) {
//        switch action {
//        case .changeSearchText(let string):
//            searchText = string
//        
//        case .fetchLaunches(let isPullToRefresh):
//            if !isPullToRefresh {
//                fetchingState = .loading
//            }
//            
//            Task {
//                if isPullToRefresh {
//                    try? await Task.sleep(for: .seconds(0.3))
//                }
//                
////                let result = await network.fetchUpcoming()//fetchArrayData()
//                
//                if isPullToRefresh {
//                    try? await Task.sleep(for: .seconds(0.3))
//                }
//                
//                
////                switch result {
////                case .success(let launch):
////                    fetchingState = .success(launch)
////                case .failure(let failure):
////                    fetchingState = .error(failure)
////                }
//            }
//        }
//    }
//    
//    
//    enum Action {
//        case changeSearchText(String)
//        case fetchLaunches(isPullToRefresh: Bool = false)
//    }
//    
//    
//    @Published var searchText: String = ""
//    @Published var items: [Int] = []
//    @Published var fetchingState: FetchingState<[LaunchResult], Error> = .idle
//    
//    
//}

enum FetchingState<T: Equatable, E: Error> {
    
    case loading
    case idle
    case success(T)
    case error(E)
    
    var successValue: T? {
        switch self {
        case .success(let value): value
        default: nil
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success: true
        default: false
        }
    }
    
}


protocol MyObservableModel: ObservableObject {
    
    associatedtype Action
    func send(action: Action)
    
}

extension MyObservableModel {
    func binding<T>(
        for keyPath: KeyPath<Self, T>,
        action: @escaping (T) -> Action
    ) -> Binding<T> where T: Equatable {
        return Binding(
            get: { self[keyPath: keyPath] },
            set: { newValue in self.send(action: action(newValue)) }
        )
    }
}

//// Create a class to handle the API request
//class LaunchFetcher {
//    private let rM: RequestManager
//    
//    init() {
//        self.rM = RequestManager()
//    }
//
//    func fetchArrayData() async -> Result<[Launch], AppError> {
//        do {
//            // Fetch the data and response
////            let (data, _) = try await URLSession.shared.data(from: url)
////            
////            // Decode the data into the specified type (an array of T)
////            let decodedData = try JSONDecoder().decode([Launch].self, from: data)
//            let decodedData = try await self.rM.fetchLaunches()
//            return .success(decodedData.launches)
//        } catch {
//            
//            if let afError = error.asAFError {
//                return .failure(.af(afError))
//            } else {
//                return .failure(.unknown)
//            }
//        }
//    }
//    
//    func fetchUpcoming() async throws -> [LaunchResult] {
//        do {
//            // Fetch the data and response
////            let (data, _) = try await URLSession.shared.data(from: url)
////
////            // Decode the data into the specified type (an array of T)
////            let decodedData = try JSONDecoder().decode([Launch].self, from: data)
//            let decodedData = try await self.rM.fetchUpcomingLaunches()
//            print(decodedData)
//            return decodedData.results
//        } catch {
//            print(error)
//            if let afError = error.asAFError {
//                throw AppError.af(afError)
//            } else {
//                throw AppError.unknown
//            }
//        }
//    }
//}

import UserNotifications

func scheduleLocalizedNotification() {
    let center = UNUserNotificationCenter.current()
    
    let content = UNMutableNotificationContent()
    content.title = NSLocalizedString("Odlet zacina o 15min", comment: "")
    content.body = NSLocalizedString("Notifikacia funguje", comment: "")
    content.sound = .default

    // Trigger in 10 seconds
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)

    let request = UNNotificationRequest(identifier: "localReminder", content: content, trigger: trigger)

    center.add(request) { error in
        if let error = error {
            print("Notification error: \(error.localizedDescription)")
        }
    }
}



import MapKit

struct LaunchView: View {
    
    @State private var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Example: San Francisco coordinates
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        var body: some View {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                .onAppear {
                    // You can perform actions when the view appears
                    print("Map is ready")
                }
                .edgesIgnoringSafeArea(.all) // To make the map fill the screen
        }
}

