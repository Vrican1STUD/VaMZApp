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
            Text("Specification")
                .frame(maxWidth: .infinity, alignment: . leading)
                .font(.title3)
            if let lCost = rocketConfig.launchCost  {
                SpecRow(title: "Cost per Launch", value: "\(lCost.formatted()) $" )
            } else {
                SpecRow(title: "Cost per Launch", value: "Undefined" )
            }
            if let lLength = rocketConfig.length  {
                SpecRow(title: "Height", value: "\(lLength.formatted()) m" )
            } else {
                SpecRow(title: "Height", value: "Undefined" )
            }
            if let lMass = rocketConfig.launchMass  {
                SpecRow(title: "Mass", value: "\(lMass.formatted()) t" )
            } else {
                SpecRow(title: "Mass", value: "Undefined" )
            }
            SpecRow(title: "Is reusable", value: rocketConfig.reusable ? "Yes" : "No")
            SpecRow(title: "Launch Success Rate",
                    value: rocketConfig.launchSuccessRate >= 0 ? "\(rocketConfig.launchSuccessRate) %" : "Undefined")
            SpecRow(title: "Landing Success Rate",
                    value: rocketConfig.landingSuccessRate >= 0 ? "\(rocketConfig.landingSuccessRate) %" : "Undefined")
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        
    }

}

#Preview {
    RocketSpecificationView(rocketConfig: RocketConfiguration(name: "Falcon 9", reusable: true, wikiUrl: "https://en.wikipedia.org/wiki/Falcon_9", description: "Falcon 9 is a two-stage rocket designed and manufactured by SpaceX for the reliable and safe transport of satellites and the Dragon spacecraft into orbit. The Block 5 variant is the fifth major interval aimed at improving upon the ability for rapid reusability.", alias: "", minStage: 1, maxStage: 2, length: 70, diameter: 3.65, launchCost: 52000000, launchMass: 540, leoCapacity: 22800, totalLaunchCount: 405, consecutiveSuccessfulLaunches: 107, successfulLaunches: 404, failedLaunches: 1,pendingLaunches: 106, attemptedLandings: 397, successfulLandings: 392, failedLandings: 5))
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
