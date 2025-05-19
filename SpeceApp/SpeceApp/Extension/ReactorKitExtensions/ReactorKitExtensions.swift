//
//  ReactorKitExtensions.swift
//  SpeceApp
//
//  Created by Ja on 16/05/2025.
//

import SwiftUI
import Combine
import ReactorKit

extension Reactor {
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

extension Publisher {
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
