//
//  LaunchErrorView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct LaunchErrorView: View {
    
    let error: AppError
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(.astronaut)
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .padding(.bottom, 32)
            
            Text(error.localizedDescription)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
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
