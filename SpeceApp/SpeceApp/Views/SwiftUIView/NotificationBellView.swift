//
//  NotificationBellView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

// MARK: - NotificationBellView

/// A bell icon that indicates notification status and can be toggled.
/// Shows a filled bell if saved, an outlined bell otherwise, with color depending on permission.
struct NotificationBellView: View {
    
    // MARK: Properties
    
    /// Size of the bell icon
    let bellSize: CGFloat
    
    /// Indicates if the notification can be manipulated (enabled/disabled)
    let canManipulate: Bool
    
    /// Indicates if the notification is currently saved/enabled
    let isSaved: Bool
    
    /// The date/time associated with the notification (used externally)
    let netDate: Date
    
    /// Closure to call when bell is tapped
    let onTap: () -> Void
    
    // MARK: Computed Properties
    
    /// Determines the color of the bell based on manipulation ability
    var bellColor: Color {
        canManipulate ? Color.App.Bell.notify : Color.App.Bell.save
    }
    
    // MARK: Body
    
    var body: some View {
        VStack {
            Image(systemName: isSaved ? "bell.fill" : "bell")
                .resizable()
                .scaledToFit()
                .transition(.scale.combined(with: .opacity))
                .frame(width: bellSize)
                .foregroundStyle(bellColor)
                .id(isSaved) // triggers transition animation on toggle
        }
        .animation(.bouncy, value: isSaved)
        .onTapGesture {
            onTap()
        }
    }
}
