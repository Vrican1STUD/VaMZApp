//
//  CachedValue.swift
//  SpeceApp
//
//  Created by Ja on 18/04/2025.
//

import Foundation
import Combine

// MARK: - CachedValue Property Wrapper

/// A property wrapper that stores Codable & Equatable values in UserDefaults and publishes changes.
@propertyWrapper
final class CachedValue<T: Codable & Equatable> {
    
    // MARK: - Private Properties
    
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults
    private let subject: CurrentValueSubject<T, Never>
    
    // MARK: - Wrapped and Projected Values
    
    /// The wrapped value accessed via the property.
    var wrappedValue: T {
        get { load() }
        set { save(newValue) }
    }
    
    /// A Combine publisher that emits whenever the value changes.
    var projectedValue: AnyPublisher<T, Never> {
        subject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    /// Creates a new cached value wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value.
    ///   - key: The key used in UserDefaults.
    ///   - userDefaults: The UserDefaults instance to use. Defaults to `.standard`.
    init(wrappedValue: T, _ key: String, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.userDefaults = userDefaults
        let loaded = Self.loadValue(forKey: key, defaultValue: wrappedValue, userDefaults: userDefaults)
        self.subject = CurrentValueSubject(loaded)
    }
    
    // MARK: - Private Methods
    
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
