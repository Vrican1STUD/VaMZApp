//
//  LaunchStatusView.swift
//  SpeceApp
//
//  Created by Ja on 19/05/2025.
//

import SwiftUI

struct LaunchStatusView: View {
    
    let launchStatus: LaunchStatus

    var body: some View {
        VStack{
            Divider()
                .frame(height: 1)
                .background(Color.gray)

            Text(launchStatus.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(launchStatus.color)

            Divider()
                .frame(height: 1)
                .background(Color.gray)
        }
    }
}
