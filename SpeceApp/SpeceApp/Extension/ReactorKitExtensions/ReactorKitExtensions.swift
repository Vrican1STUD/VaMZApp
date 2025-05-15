//
//  ReactorKitExtensions.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import ReactorKit

extension Reactor {
    /// Creates a SwiftUI `Binding` from a `KeyPath` to the state and a setter that maps the new value into an `Action`.
    ///
    /// - Parameters:
    ///   - keyPath: KeyPath to the state property
    ///   - setter: Closure mapping the new value to an `Action`
    /// - Returns: A SwiftUI Binding
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        set setter: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.currentState[keyPath: keyPath] },
            set: { newValue in self.action.onNext(setter(newValue)) }
        )
    }
}
