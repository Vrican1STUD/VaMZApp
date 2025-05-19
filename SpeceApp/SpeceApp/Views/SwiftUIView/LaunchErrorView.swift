//
//  LaunchErrorView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - LaunchErrorView

/// A view to display an error message with a retry button.
struct LaunchErrorView: View {
    
    // MARK: Properties
    
    /// The error to display
    let error: AppError
    
    /// The action to perform when retry button is tapped
    let onRetry: () -> Void

    // MARK: Body
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Astronaut image with fixed size and padding
            Image(.astronaut)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 32)
            
            // Error message, centered with horizontal padding
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Retry button with background and rounded corners
            Button(action: onRetry) {
                Text(String(localized: "error.retry"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 60)
                    .background(Color.App.Button.normal)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.scaled)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .padding()
    }
}

