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
            Text("Home")
                .tabItem { Label("Home", systemImage: "house.fill") }
            NavigationStack {
                LaunchesView2()
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

