//
//  CountdownView.swift
//  SpeceApp
//
//  Created by Ja on 20/04/2025.
//

import SwiftUI

struct CountdownView: View {
    let remainingTime: TimeInterval
    
    var body: some View {
        // Calculate the days, hours, minutes, and seconds directly in the view
        let days = abs(Int(remainingTime) / (60 * 60 * 24))
        let hours = abs((Int(remainingTime) % (60 * 60 * 24)) / (60 * 60))
        let minutes = abs((Int(remainingTime) % (60 * 60)) / 60)
        let seconds = abs(Int(remainingTime) % 60)
        
        HStack (spacing: 0) {
            if remainingTime < 0 {
                VStack {
                    Text("-")
                        .font(.largeTitle)
                        .bold()
                    Text("")
                        .font(.caption)
                }
            }
            
            HStack (spacing: 18) {
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
                VStack {
                    Text(String(format: "%02d", seconds))
                        .font(.largeTitle)
                        .bold()
                    Text("SECONDS")
                        .font(.caption)
                }
            }
        }
    }
}
