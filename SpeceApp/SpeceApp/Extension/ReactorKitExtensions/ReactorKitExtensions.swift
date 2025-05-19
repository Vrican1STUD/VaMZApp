//
//  ReactorKitExtensions.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit

// MARK: - Reactor State Binding

extension Reactor {
    /// Creates a `Binding` between a Reactor state key path and an action-producing setter.
    ///
    /// This allows SwiftUI views to bind directly to ReactorKit state in a reactive way.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to the specific value in the Reactor's state.
    ///   - setter: A closure that maps a new value to a Reactor `Action`.
    /// - Returns: A `Binding` that reflects the Reactor state and dispatches actions on set.
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

// MARK: - Combine to RxSwift Interop

extension Publisher {
    /// Converts a Combine `Publisher` into an RxSwift `Observable`.
    ///
    /// Useful when working in a hybrid project using both Combine and RxSwift (e.g., with ReactorKit).
    /// - Returns: An RxSwift `Observable` representing the same stream.
    func asObservable() -> Observable<Output> {
        Observable.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        observer.onError(error)
                    } else {
                        observer.onCompleted()
                    }
                },
                receiveValue: {
                    observer.onNext($0)
                }
            )
            
            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}
