//
//  LaunchResponse.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import SwiftUI

struct LaunchResponse: Decodable, Equatable {
    
    let count: Int?
    let next: String?
    let results: [LaunchResult]
    
    var nextPagingUrl: URL? {
        guard let next, let url = URL(string: next) else { return nil }
        return url
    }
}

struct LaunchResult: Codable, Equatable, Identifiable, Hashable {
    
    let id: String
    let url: String
    let name: String
    let slug: String
    let status: LaunchStatus
    let lastUpdated, net: String?
    let windowEnd, windowStart: String?
    let image: LaunchImage?
    
    var netString: String? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date?.string(format: .ddMMYYYY)
    }
    
    var netDate: Date? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date
    }
    
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
    }
    
    // Needed for Hashable
    static func == (lhs: LaunchResult, rhs: LaunchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension LaunchResult {
    
    static func mock(name: String = "TestLaunch", offset: TimeInterval = 180) -> LaunchResult {
        LaunchResult(
            id: "a150bf95-0152-410d-9657-423608ddfab4",
            url: "",
            name: name,
            slug: "",
            status: .goForLaunch,
            lastUpdated: "",
            net: Date().addingTimeInterval(offset).ISO8601Format().uppercased(),
            windowEnd: "",
            windowStart: "",
            image: LaunchImage(
                imageUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png",
                thumbnailUrl: "https://thespacedevs-prod.nyc3.digitaloceanspaces.com/media/images/255bauto255d__image_thumbnail_20240305192320.png"
            )
        )
    }
}

enum LaunchStatus: Int, Codable {
    
    case goForLaunch = 1
    case toBeDetermined = 2
    case launchSuccessful = 3
    case launchFailure = 4
    case onHold = 5
    case inFlight = 6
    case partialFailure = 7
    case toBeConfirmed = 8
    case payloadDeployed = 9
    case unknown = -1
    
    var name: String {
        switch self {
        case .goForLaunch: return String(localized: "lunch.status.full.go")
        case .toBeDetermined: return String(localized: "lunch.status.full.tbd")
        case .launchSuccessful: return String(localized: "lunch.status.full.success")
        case .launchFailure: return String(localized: "lunch.status.full.failure")
        case .onHold: return String(localized: "lunch.status.full.hold")
        case .inFlight: return String(localized: "lunch.status.full.flight")
        case .partialFailure: return String(localized: "lunch.status.full.pfailure")
        case .toBeConfirmed: return String(localized: "lunch.status.full.tbc")
        case .payloadDeployed: return String(localized: "lunch.status.full.deployed")
        case .unknown: return String(localized: "lunch.status.full.unk")
        }
    }
    
    var abbrev: String {
        switch self {
        case .goForLaunch: return String(localized: "lunch.status.abbrev.go")
        case .toBeDetermined: return String(localized: "lunch.status.abbrev.tbd")
        case .launchSuccessful: return String(localized: "lunch.status.abbrev.success")
        case .launchFailure: return String(localized: "lunch.status.abbrev.failure")
        case .onHold: return String(localized: "lunch.status.abbrev.hold")
        case .inFlight: return String(localized: "lunch.status.abbrev.flight")
        case .partialFailure: return String(localized: "lunch.status.abbrev.pfailure")
        case .toBeConfirmed: return String(localized: "lunch.status.abbrev.tbc")
        case .payloadDeployed: return String(localized: "lunch.status.abbrev.deployed")
        case .unknown: return String(localized: "lunch.status.abbrev.unk")
        }
    }
    
    var color: Color {
        switch self {
        case .goForLaunch:
            return Color.teal              // Confident and ready
        case .toBeDetermined:
            return Color.gray // Uncertain or placeholder
        case .launchSuccessful:
            return Color.green             // Success and positivity
        case .launchFailure:
            return Color(red: 0.8, green: 0.0, blue: 0.0) // Deeper red for dramatic failure
        case .onHold:
            return Color.yellow            // Caution / waiting
        case .inFlight:
            return Color.indigo            // Mysterious, high-energy phase
        case .partialFailure:
            return Color(red: 1.0, green: 0.6, blue: 0.0) // Amber orange for mixed results
        case .toBeConfirmed:
            return Color.orange            // Warning / pending confirmation
        case .payloadDeployed:
            return Color.cyan              // Cool, clean finish
        case .unknown:
            return Color.secondary         // Default fallback
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        self = LaunchStatus(rawValue: id) ?? .unknown
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rawValue, forKey: .id)
    }

    private enum CodingKeys: String, CodingKey {
        case id
    }
}

struct FormattedNameModel {
    
    let name: String
    let mission: String
    
    init(name: String) {
        let components = name.components(separatedBy: " | ")
        self.name = components.first ??  "-"
        self.mission = components.last ?? "-"
    }
}

struct LaunchImage: Codable, Equatable {
    
    let imageUrl: String
    let thumbnailUrl: String
    
    var imageBigUrl: URL? {
        URL(string: imageUrl)
    }
    
    var imageThumbnailUrl: URL? {
        URL(string: thumbnailUrl)
    }
}
