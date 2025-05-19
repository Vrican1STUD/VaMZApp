//
//  CountdownView.swift
//  SpeceApp
//
//  Created by Ja on 20/04/2025.
//

import SwiftUI

struct CountdownView: View {
    
    // MARK: - Properties
    
    /// Remaining time interval in seconds (can be negative if time passed)
    let remainingTime: TimeInterval
    
    // MARK: - Computed Properties
    
    /// Breaks down the remaining time into days, hours, minutes, and seconds components
    private var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let totalSeconds = abs(Int(remainingTime))
        
        var days = totalSeconds / (60 * 60 * 24)
        let hours = (totalSeconds % (60 * 60 * 24)) / (60 * 60)
        let minutes = (totalSeconds % (60 * 60)) / 60
        let seconds = totalSeconds % 60
        
        // Cap days at 999 to avoid overly large displays
        if days > 999 { days = 999 }
        
        return (days, hours, minutes, seconds)
    }
    
    // MARK: - Body
    
    var body: some View {
        let (days, hours, minutes, seconds) = timeComponents
        
        HStack(spacing: 0) {
            // Show minus sign if countdown is negative (time passed)
            if remainingTime < 0 {
                VStack {
                    Text("-")
                        .font(.largeTitle)
                        .bold()
                    Text("") // Empty placeholder for alignment
                        .font(.caption)
                }
            }
            
            // Display each time component with spacing
            HStack(spacing: 18) {
                timeBlock(days, String(localized: "countdown.days"))
                timeBlock(hours, String(localized: "countdown.hours"))
                timeBlock(minutes, String(localized: "countdown.minutes"))
                timeBlock(seconds, String(localized: "countdown.seconds"))
            }
        }
    }
    
    // MARK: - Private View Builders
    
    /// A reusable view component for displaying a time value and its label
    /// - Parameters:
    ///   - value: The numeric time value (e.g., hours, minutes)
    ///   - label: The localized label string for the time unit
    /// - Returns: A vertically stacked view showing the value and label
    private func timeBlock(_ value: Int, _ label: String) -> some View {
        VStack {
            Text(String(format: "%02d", value))
                .font(.largeTitle)
                .monospacedDigit() // Ensures digits have uniform width
                .bold()
            Text(label)
                .font(.caption)
        }
    }
}
