//
//  CountdownView.swift
//  SpeceApp
//
//  Created by Ja on 20/04/2025.
//

import SwiftUI

struct CountdownView: View {
    
    let remainingTime: TimeInterval
    
    private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = abs(Int(remainingTime))
        var days = totalSeconds / (60 * 60 * 24)
        let hours = (totalSeconds % (60 * 60 * 24)) / (60 * 60)
        let minutes = (totalSeconds % (60 * 60)) / 60
        let seconds = totalSeconds % 60
        
        if days > 999 { days = 999 }
        
        return (days, hours, minutes, seconds)
    }
    
    private func timeBlock(_ value: Int, _ label: String) -> some View {
        VStack {
            Text(String(format: "%02d", value))
                .font(.largeTitle)
                .monospacedDigit()
                .bold()
            Text(label)
                .font(.caption)
        }
    }
    
    var body: some View {
        let (days, hours, minutes, seconds) = timeComponents
        
        HStack(spacing: 0) {
            if remainingTime < 0 {
                VStack {
                    Text("-")
                        .font(.largeTitle)
                        .bold()
                    Text("")
                        .font(.caption)
                }
            }
            HStack(spacing: 18) {
                timeBlock(days, String(localized: "countdown.days"))
                timeBlock(hours, String(localized: "countdown.hours"))
                timeBlock(minutes, String(localized: "countdown.minutes"))
                timeBlock(seconds, String(localized: "countdown.seconds"))
            }
        }
    }
}
