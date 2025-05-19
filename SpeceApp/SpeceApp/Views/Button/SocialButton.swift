//
//  SocialButton.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct SocialButton: View {
    
    let image: ImageResource
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(image)
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(Color.App.Button.normal)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
