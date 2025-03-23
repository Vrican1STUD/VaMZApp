//
//  HomeView.swift
//  SpeceApp
//
//  Created by Ja on 12/03/2025.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        TabView {
            NavigationStack {
                CountdownView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }
            
            LaunchView()
                .tabItem { Label("Launch", systemImage: "magnifyingglass") }
        }
    }
    
}

#Preview {
    HomeView()
}

struct CountdownView: View {
    
    @ObservedObject var viewModel: CountdownViewModel = .init()
    
    var filteredItems: [String] {
        let array = (0..<100).map {"Item_\($0)"}
        return viewModel.searchText.isEmpty ? array : array.filter { $0 == viewModel.searchText }
    }
    
    
    
    var body: some View {
        ScrollView {
            LazyVStack {
                switch viewModel.fetchingState {
                case .loading:
                    ProgressView()
                
                case .idle:
                    EmptyView()
                
                case .success(let launches):
                    ForEach(launches) {
                        LaunchView2(launch: $0)
                    }
                case .error(let e):
                    Text(e.localizedDescription)
                }
            }
        }
        .searchable(
            text: viewModel.binding(for: \.searchText, action: { newValue in .changeSearchText(newValue) })
        )
        .onReceive(viewModel.$searchText, perform: { updatedValue in
            print(updatedValue)
        })
        .onAppear { viewModel.send(action: .fetchLaunches) }
    }
    
    func launch(item: String) -> some View {
        HStack {
            Text(item)
                .font(.body.bold())
                .padding()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray)
        .padding(.horizontal, 10)
    }
    
}

struct LaunchView2: View {
    
    let launch: Launch
   
    
    var body: some View {
        VStack {
            Text(launch.missionName)
               
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
    }
    
}

class CountdownViewModel: MyObservableModel {
    
    private let network: LaunchFetcher = .init()
    
    func send(action: Action) {
        switch action {
        case .changeSearchText(let string):
            searchText = string
        
        case .fetchLaunches:
            fetchingState = .loading
            Task {
                
//                try? await Task.sleep(for: .seconds(3))
                let result = await network.fetchArrayData(from: URL(string: "https://api.spacexdata.com/v3/launches")!)
                
                switch result {
                case .success(let launch):
                    fetchingState = .success(launch)
                case .failure(let failure):
                    fetchingState = .error(failure)
                }
            }
        }
    }
    
    
    enum Action {
        case changeSearchText(String)
        case fetchLaunches
    }
    
    
    @Published var searchText: String = ""
    @Published var items: [Int] = []
    @Published var fetchingState: FetchingState<[Launch], Error> = .idle
    
    
}

enum FetchingState<T: Equatable, E: Error> {
    
    case loading
    case idle
    case success(T)
    case error(E)
    
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

//API logic

import Foundation

//TODO: snake case opitmization

struct Launch: Codable, Equatable, Identifiable {
    
    static func == (lhs: Launch, rhs: Launch) -> Bool {
        lhs.flightNumber == rhs.flightNumber
    }
    
    var id: Int { flightNumber }
    
    let flightNumber: Int
    let missionName: String
    let launchYear: String
    let launchDateUTC: String
    let launchSuccess: Bool?
    let details: String?
    let links: Links
    let launchSite: LaunchSite
    let rocket: Rocket
    let launchFailureDetails: LaunchFailureDetails?

    enum CodingKeys: String, CodingKey {
        case flightNumber = "flight_number"
        case missionName = "mission_name"
        case launchYear = "launch_year"
        case launchDateUTC = "launch_date_utc"
        case launchSuccess = "launch_success"
        case details
        case links
        case launchSite = "launch_site"
        case rocket
        case launchFailureDetails = "launch_failure_details"
    }
}

struct Links: Codable {
    let missionPatch: String?
    let articleLink: String?

    enum CodingKeys: String, CodingKey {
        case missionPatch = "mission_patch"
        case articleLink = "article_link"
    }
}

struct LaunchSite: Codable {
    let siteID: String
    let siteName: String

    enum CodingKeys: String, CodingKey {
        case siteID = "site_id"
        case siteName = "site_name"
    }
}

struct Rocket: Codable {
    let rocketName: String
    let rocketType: String

    enum CodingKeys: String, CodingKey {
        case rocketName = "rocket_name"
        case rocketType = "rocket_type"
    }
}

struct LaunchFailureDetails: Codable {
    let time: Int
    let reason: String
}

// Create a class to handle the API request
class LaunchFetcher {

    func fetchArrayData(from url: URL) async -> Result<[Launch], Error> {
        do {
            // Fetch the data and response
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Decode the data into the specified type (an array of T)
            let decodedData = try JSONDecoder().decode([Launch].self, from: data)
            
            return .success(decodedData)
        } catch {
            return .failure(error)
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

