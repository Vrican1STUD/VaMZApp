//
//  ScaledButtonStyle.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct ScaledButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaledButtonStyle {
    static var scaled: Self { ScaledButtonStyle() }
}
