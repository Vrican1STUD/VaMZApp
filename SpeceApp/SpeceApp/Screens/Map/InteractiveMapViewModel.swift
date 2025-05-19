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
    
    // MARK: - Actions
    
    enum Action {
        case setActualLocation(MapPointLocation?)
    }
    
    // MARK: - Mutations
    
    enum Mutation {
        case didUpdateActualLocation(MapPointLocation?)
    }
    
    // MARK: - State
    
    struct State {
        var actualLocation: MapPointLocation?
    }
    
    // MARK: - Properties
    
    var initialState: State
    
    // MARK: - Initialization
    
    init() {
        self.initialState = State(actualLocation: nil)
    }
    
    // MARK: - Mutate
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setActualLocation(let mapPointLocation):
            return Observable.just(Mutation.didUpdateActualLocation(mapPointLocation))
        }
    }
    
    // MARK: - Reduce
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case .didUpdateActualLocation(let mapPointLocation):
            state.actualLocation = mapPointLocation
        }
        
        return state
    }
}
