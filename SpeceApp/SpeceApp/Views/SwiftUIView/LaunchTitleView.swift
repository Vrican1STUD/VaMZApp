//
//  LaunchTitleView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - LaunchTitleView

/// A view displaying the launch name and mission with styled text.
struct LaunchTitleView: View {
    
    // MARK: Properties
    
    /// The name of the launch
    let name: String
    
    /// The mission description or title
    let mission: String

    // MARK: Body
    
    var body: some View {
        VStack(alignment: .leading) {
            // Launch name styled prominently
            Text(name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.Text.primary)
            
            // Mission title styled as secondary heading
            Text(mission)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.Text.info)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }
}
