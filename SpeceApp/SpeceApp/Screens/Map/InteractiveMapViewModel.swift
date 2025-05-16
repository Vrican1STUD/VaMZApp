//
//  InteractiveMapViewModel.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit
import MapKit

final class InteractiveMapViewViewModel: Reactor {
    
    enum Action {
        case setActualLocation(MapPointLocation?)
        case setCenterCoordinate(CLLocationCoordinate2D)
    }
    
    enum Mutation {
        case didUpdateActualLocation(MapPointLocation?)
        case didUpdateCenterCoordinate(CLLocationCoordinate2D)
    }
    
    struct State {
        var actualLocation: MapPointLocation?
        var centerCoordinate: CLLocationCoordinate2D
        var region: MKCoordinateRegion {
            return MKCoordinateRegion( center: centerCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        }
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(actualLocation: nil, centerCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setActualLocation(let mapPointLocation):
            return Observable.just(Mutation.didUpdateActualLocation(mapPointLocation))
        case .setCenterCoordinate(let centerCoordinate):
            return Observable.just(Mutation.didUpdateCenterCoordinate(centerCoordinate))
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateActualLocation(let mapPointLocation):
            state.actualLocation = mapPointLocation
        case .didUpdateCenterCoordinate(let centerCoordinate):
            state.centerCoordinate = centerCoordinate
        }

        return state
        
    }
}

