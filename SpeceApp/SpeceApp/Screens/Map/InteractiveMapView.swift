//
//  InteractiveMapView.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import MapKit
import SwiftUIReactorKit

struct InteractiveMapView: ReactorView {
    
    // MARK: - Properties
    
    var reactor: InteractiveMapViewViewModel
    @State private var camera: MapCameraPosition = .automatic
    
    // MARK: - Body
    
    func body(reactor: InteractiveMapViewViewModel.ObservableObject) -> some View {
        Map(position: $camera) {
            if let annotation = reactor.state.actualLocation {
                Annotation(annotation.name, coordinate: annotation.coordinate) {
                    VStack(spacing: 4) {
                        Image(systemName: "location.north.circle.fill")
                            .font(.title)
                            .foregroundColor(annotation.color)
                    }
                    .tag(annotation.id)
                }
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
