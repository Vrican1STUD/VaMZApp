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
    }
    
    enum Mutation {
        case didUpdateActualLocation(MapPointLocation?)
    }
    
    struct State {
        var actualLocation: MapPointLocation?
    }
    
    var initialState: State
    
    init() {
        self.initialState = State(actualLocation: nil)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setActualLocation(let mapPointLocation):
            return Observable.just(Mutation.didUpdateActualLocation(mapPointLocation))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateActualLocation(let mapPointLocation):
            state.actualLocation = mapPointLocation
        }

        return state
    }
}
