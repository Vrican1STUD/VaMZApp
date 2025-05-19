//
//  LaunchDetailResponse.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import Foundation
import SwiftUI
import MapKit

// MARK: - Launch Detail Result Model

/// Detailed information about a launch, including rocket, pad, and videos
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
    
    /// Parsed name components from full name string
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
    }
    
    /// Social media URLs constructed from rocket wiki and videos
    var socailMediaUrls : SocialLinksModel {
        .init(wikiUrl: rocket.configuration.wikiUrl, vidUrls: vidUrls)
    }

    /// Parsed launch date from `net` string
    var netDate: Date? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date
    }
    
    /// Map location data for the launch pad
    var padLocation: MapPointLocation {
        .init(name: formattedNameModel.name, color: status.color, coordinate: CLLocationCoordinate2D(latitude: pad.latitude, longitude: pad.longitude))
    }
}

// MARK: - Map Point Location Model

/// Represents a location point on a map with name, color and coordinates
struct MapPointLocation: Identifiable, Equatable {
    
    var id: String { name + coordinate.latitude.description + coordinate.longitude.description }
    let name: String
    let color: Color
    let coordinate: CLLocationCoordinate2D
    
    // Equality based on latitude and longitude coordinates
    static func == (lhs: MapPointLocation, rhs: MapPointLocation) -> Bool {
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.coordinate.latitude == rhs.coordinate.latitude
    }
}

// MARK: - Social Links Model

/// Holds wiki URL and video URLs related to the launch
struct SocialLinksModel {
    
    let wikiUrl: URL?
    let vidUrls: [URL]
    
    /// Initialize from optional wiki URL string and array of VidURL objects
    init(wikiUrl: String?, vidUrls: [VidURL]) {
        if let wUrl = wikiUrl {
            self.wikiUrl = URL(string: wUrl)
        } else {
            self.wikiUrl = nil
        }
        
        self.vidUrls = vidUrls.compactMap { URL(string: $0.url) }
    }
}

// MARK: - Info URL Model

/// Simple model wrapping a URL string
struct InfoURL: Codable, Equatable {
    
    let url: String
}

// MARK: - Video URL Model

/// Model representing a video URL string
struct VidURL: Codable, Equatable {

    let url: String
}

// MARK: - Launch Pad Model

/// Launch pad information including location and description
struct Pad: Codable, Equatable {
    
    let name: String
    let description: String?
    let latitude, longitude: Double
    let mapImage: String
    
    /// Provides detailed description or fallback to pad name if description is empty
    var detailDescription: String {
        if let description = description, !description.isEmpty {
            return description
        } else {
            return name
        }
    }
}

// MARK: - Rocket Detail Model

/// Detailed rocket information including configuration data
struct DetailRocket: Codable, Equatable {
    
    let id: Int
    let configuration: RocketConfiguration
}

// MARK: - Rocket Configuration Model

/// Detailed configuration of a rocket including stats and URLs
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

    /// Calculates percentage of successful launches (returns -1 if no launches)
    var launchSuccessRate: Int {
        let totalLaunches = failedLaunches + successfulLaunches
        if totalLaunches == 0 { return -1 }
        let percent = Double(successfulLaunches) / Double(totalLaunches) * 100
        return Int(percent)
    }
    
    /// Calculates percentage of successful landings (returns -1 if no attempts)
    var landingSuccessRate: Int {
        let totalAttempts = successfulLandings + failedLandings
        if totalAttempts == 0 { return -1 }
        let percent = Double(successfulLandings) / Double(totalAttempts) * 100
        return Int(percent)
    }
}
