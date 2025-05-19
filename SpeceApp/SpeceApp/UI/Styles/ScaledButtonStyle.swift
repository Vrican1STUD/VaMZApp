//
//  ScaledButtonStyle.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - ScaledButtonStyle

/// A button style that scales down and reduces opacity when pressed,
struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.default, value: configuration.isPressed)    }
}

// MARK: - ButtonStyle Extension

extension ButtonStyle where Self == ScaledButtonStyle {
    /// Convenient static property to use `.scaled` style easily
    static var scaled: Self { ScaledButtonStyle() }
}
