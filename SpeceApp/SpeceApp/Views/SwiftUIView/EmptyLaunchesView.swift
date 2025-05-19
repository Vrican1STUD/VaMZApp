//
//  EmptyLaunchesView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - EmptyLaunchesView

/// A view displayed when there are no launches to show.
struct EmptyLaunchesView: View {
    
    // MARK: Properties
    
    /// The descriptive text to display when no launches are available
    let description: String

    // MARK: Body
    
    var body: some View {
        VStack {
            Spacer()
            
            // Astronaut image placeholder
            Image(.astronaut)
            
            // Description text, centered and padded horizontally
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .transition(.opacity) // Fade transition when view appears/disappears
    }
}
