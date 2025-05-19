//
//  LaunchTitleView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct LaunchTitleView: View {
    
    let name: String
    let mission: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.Text.primary)
            
            Text(mission)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.Text.info)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
    }
}
