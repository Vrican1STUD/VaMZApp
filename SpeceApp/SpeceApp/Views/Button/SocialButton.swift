//
//  SocialButton.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - SocialButton

/// A customizable button displaying an image for social media actions.
struct SocialButton: View {
    
    // MARK: Properties
    
    /// The image resource to display inside the button
    let image: ImageResource
    
    /// Closure executed when the button is tapped
    let action: () -> Void
    
    // MARK: Body
    
    var body: some View {
        Button(action: action) {
            Image(image)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.App.Button.normal)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(.plain) // disables default button style for custom appearance
    }
}
