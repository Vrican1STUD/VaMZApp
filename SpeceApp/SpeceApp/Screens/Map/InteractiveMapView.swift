//
//  InteractiveMapView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import MapKit
import SwiftUIReactorKit

struct Location: Identifiable {
    var id: String { name + coordinate.latitude.description + coordinate.longitude.description }
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct InteractiveMapView: ReactorView {
    
    var reactor: InteractiveMapViewViewModel
    @State var camera: MapCameraPosition = .automatic
    
    func body(reactor: InteractiveMapViewViewModel.ObservableObject) -> some SwiftUI.View {
        Map(position: $camera) {
            if let annotation = reactor.state.actualLocation {
                Marker(coordinate: annotation.coordinate, label: { Text(annotation.name) })
                    .tag(annotation.id)
            }
        }
        .mapStyle(.standard)
        .onChange(of: reactor.state.actualLocation) { oldValue, newValue in
            guard let newValue else { return }
            withAnimation(.default.delay(0.3)) {
                camera = .region(.init(center: newValue.coordinate, span: .init(latitudeDelta: 100, longitudeDelta: 100)))
            }
        }
    }
  
}
