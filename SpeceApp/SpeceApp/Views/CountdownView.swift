//
//  CountdownView.swift
//  SpeceApp
//
//  Created by Ja on 20/04/2025.
//

import SwiftUI

struct CountdownView: View {
    let days: Int
    let hours: Int
    let minutes: Int
    
    var body: some View {
        HStack (spacing: 26) {
            VStack {
                Text(String(format: "%02d", days))
                    .font(.largeTitle)
                    .bold()
                Text("DAYS")
                    .font(.caption)
            }
            VStack {
                Text(String(format: "%02d", hours))
                    .font(.largeTitle)
                    .bold()
                Text("HOURS")
                    .font(.caption)
            }
            VStack {
                Text(String(format: "%02d", minutes))
                    .font(.largeTitle)
                    .bold()
                Text("MINUTES")
                    .font(.caption)
            }
        }
    }
}

#Preview {
    CountdownView(days: 20, hours: 10, minutes: 5)
}
