//
//  CachedValue.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import Foundation
import Combine

@propertyWrapper
final class CachedValue<T: Codable & Equatable> {
    
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<T, Never>

    var wrappedValue: T {
        get { load() }
        set { save(newValue) }
    }

    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }

    init(wrappedValue: T, _ key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.userDefaults = userDefaults
        let loaded = Self.loadValue(forKey: key, defaultValue: wrappedValue, userDefaults: userDefaults)
        self.subject = CurrentValueSubject(loaded)
    }

    private func load() -> T {
        Self.loadValue(forKey: key, defaultValue: defaultValue, userDefaults: userDefaults)
    }

    private func save(_ value: T) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        userDefaults.set(data, forKey: key)
        subject.send(value)
    }

    private static func loadValue(forKey key: String, defaultValue: T, userDefaults: UserDefaults) -> T {
        guard let data = userDefaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode(T.self, from: data)
        else {
            return defaultValue
        }
        return decoded
    }
}
