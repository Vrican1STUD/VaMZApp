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
    
    var reactor: InteractiveMapViewViewModel
    @State var camera: MapCameraPosition = .automatic
    
    func body(reactor: InteractiveMapViewViewModel.ObservableObject) -> some SwiftUI.View {
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
