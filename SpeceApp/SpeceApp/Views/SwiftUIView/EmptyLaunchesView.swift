//
//  EmptyLaunchesView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct EmptyLaunchesView: View {
    
    let description: String

    var body: some View {
        VStack {
            Spacer()
            Image(.astronaut)
            
            Text(description)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .transition(.opacity)
    }
}
