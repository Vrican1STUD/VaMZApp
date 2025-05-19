//
//  LaunchStatusView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - LaunchStatusView

/// A view that displays the current launch status with styled text and separators.
struct LaunchStatusView: View {
    
    // MARK: Properties
    
    /// The status of the launch to display
    let launchStatus: LaunchStatus

    // MARK: Body
    
    var body: some View {
        VStack {
            // Top divider line
            Divider()
                .frame(height: 1)
                .background(Color.App.SegmentControl.line)
            
            // Status name text styled with color and font
            Text(launchStatus.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(launchStatus.color)
            
            // Bottom divider line
            Divider()
                .frame(height: 1)
                .background(Color.App.SegmentControl.line)
        }
    }
}
