//
//  RocketSpecificationView.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import SwiftUI

struct RocketSpecificationView: View {
    
    let rocketConfig: RocketConfiguration
    
    var body: some View {
        VStack(spacing: 25) {
            Text(String(localized: "launch.spec"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
            
            SpecRow(title: String(localized: "launch.spec.cost"), value: formattedCurrency(rocketConfig.launchCost))
            SpecRow(title: String(localized: "launch.spec.height"), value: formattedNumber(rocketConfig.length, unit: String(localized: "launch.spec.m")))
            SpecRow(title: String(localized: "launch.spec.mass"), value: formattedNumber(rocketConfig.launchMass, unit: String(localized: "launch.spec.t")))
            SpecRow(title: String(localized: "launch.spec.reusable" ), value: rocketConfig.reusable ? String(localized: "launch.spec.yes") : String(localized: "launch.spec.no"))
            SpecRow(title: String(localized: "launch.spec.lchrate"), value: formattedPercent(rocketConfig.launchSuccessRate))
            SpecRow(title: String(localized: "launch.spec.ldrate"), value: formattedPercent(rocketConfig.landingSuccessRate))
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
    }
    // chatGPT helped me with this formating
    private func formattedCurrency(_ value: Float?) -> String {
        guard let value = value else { return String(localized: "launch.spec.undefined") }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value) $"
    }
    
    private func formattedNumber(_ value: Float?, unit: String) -> String {
        guard let value = value else { return String(localized: "launch.spec.undefined") }
        let formattedValue = String(format: "%.2f", value)
        return "\(formattedValue) \(unit)"
    }
    
    private func formattedPercent(_ value: Int) -> String {
        value >= 0 ? "\(value) %" : String(localized: "launch.spec.undefined")
    }
}

struct SpecRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title.uppercased())
                .foregroundStyle(Color.Text.parameters)
            Spacer()
            Text(value.uppercased())
        }
    }
}

#Preview {
    RocketSpecificationView(rocketConfig: RocketConfiguration(name: "Falcon 9", reusable: true, wikiUrl: "https://en.wikipedia.org/wiki/Falcon_9", description: "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit. The Block 5 variant is the fifth major interval aimed at improving upon the ability for rapid reusability.", alias: "", minStage: 1, maxStage: 2, length: 70, diameter: 3.65, launchCost: 52000000, launchMass: 540, leoCapacity: 22800, totalLaunchCount: 405, consecutiveSuccessfulLaunches: 107, successfulLaunches: 404, failedLaunches: 1,pendingLaunches: 106, attemptedLandings: 397, successfulLandings: 392, failedLandings: 5))
}
