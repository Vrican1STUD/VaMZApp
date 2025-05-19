//
//  NotificationBellView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct NotificationBellView: View {
    
    let bellSize: CGFloat
    let canManipulate: Bool
    let isSaved: Bool
    let netDate: Date
    let onTap: () -> Void
    
    var bellColor: Color {
        return canManipulate ? .red : .white
    }
    
    var body: some View {
        VStack {
            Image(systemName: isSaved ? "bell.fill" : "bell")
                .resizable()
                .scaledToFit()
                .transition(.scale.combined(with: .opacity))
                .frame(width: bellSize)
                .foregroundStyle(bellColor)
                .id(isSaved)
        }
        .animation(.bouncy, value: isSaved)
        .onTapGesture {
            onTap()
        }
    }
}
