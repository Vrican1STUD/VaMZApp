//
//  InteractiveMapView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import MapKit

struct InteractiveMapView: View {
    
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
