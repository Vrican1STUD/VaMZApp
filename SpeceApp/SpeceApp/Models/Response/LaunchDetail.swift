//
//  Detail.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import Foundation
import SwiftUI
import MapKit

struct LaunchDetailResult: Decodable, Equatable, Identifiable {
    
    let id: String
    let url: String
    let name, slug: String
    let status: LaunchStatus
    let net: String?
    let image: LaunchImage
    let rocket: DetailRocket
    let pad: Pad
    let vidUrls: [VidURL]
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
    }
    
    var socailMediaUrls : SocialLinksModel {
        .init(wikiUrl: rocket.configuration.wikiUrl, vidUrls: vidUrls)
    }

    var netDate: Date? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date
    }
    
    var padLocation: MapPointLocation {
        .init(name: formattedNameModel.name, color: status.color, coordinate: CLLocationCoordinate2D(latitude: pad.latitude, longitude: pad.longitude))
    }
}

struct MapPointLocation: Identifiable, Equatable {
    
    var id: String { name + coordinate.latitude.description + coordinate.longitude.description }
    let name: String
    let color: Color
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: MapPointLocation, rhs: MapPointLocation) -> Bool {
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.coordinate.latitude == rhs.coordinate.latitude
    }
}

struct SocialLinksModel {
    
    let wikiUrl: URL?
    let vidUrls: [URL]
    
    init(wikiUrl: String?, vidUrls: [VidURL]) {
        if let wUrl = wikiUrl {
            self.wikiUrl = URL(string: wUrl)
        } else {
            self.wikiUrl = nil
        }
        
        self.vidUrls = vidUrls.compactMap { URL(string: $0.url) }
    }
}

struct InfoURL: Codable, Equatable {
    
    let url: String
}

struct VidURL: Codable, Equatable {

    let url: String
}

struct Pad: Codable, Equatable {
    
    let name: String
    let description: String?
    let latitude, longitude: Double
    let mapImage: String
    var detailDescription: String {
        if let description = description, !description.isEmpty {
            return description
        } else {
            return name
        }
    }
}

struct DetailRocket: Codable, Equatable {
    
    let id: Int
    let configuration: RocketConfiguration
}

struct RocketConfiguration: Codable, Equatable {
    
    let name: String
    let reusable: Bool
    let wikiUrl: String?
    let description, alias: String
    let minStage, maxStage: Float?
    let length: Float?
    let diameter: Float?
    let launchCost: Float?
    let launchMass, leoCapacity: Float?
    let totalLaunchCount, consecutiveSuccessfulLaunches, successfulLaunches, failedLaunches: Float
    let pendingLaunches, attemptedLandings, successfulLandings, failedLandings: Float

    var launchSuccessRate: Int {
        let totalLaunches = failedLaunches + successfulLaunches
        if totalLaunches == 0 { return -1 }
        let percent = Double(successfulLaunches) / Double(totalLaunches) * 100
        return Int(percent)
    }
    
    var landingSuccessRate: Int {
        let totalAttempts = successfulLandings + failedLandings
        if totalAttempts == 0 { return -1 }
        let percent = Double(successfulLandings) / Double(totalAttempts) * 100
        return Int(percent)
    }
}
