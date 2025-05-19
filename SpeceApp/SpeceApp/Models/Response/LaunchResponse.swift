//
//  LaunchResponse.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import SwiftUI

// MARK: - LaunchResponse Model

/// Represents the response containing multiple launches from the API.
struct LaunchResponse: Decodable, Equatable {
    
    /// Total number of launches in this response.
    let count: Int?
    
    /// URL string for the next page of results, if any.
    let next: String?
    
    /// List of launch results.
    let results: [LaunchResult]
    
    /// Converts `next` string to `URL` for easier paging.
    var nextPagingUrl: URL? {
        guard let next, let url = URL(string: next) else { return nil }
        return url
    }
}

// MARK: - LaunchResult Model

/// Represents a single launch with various details.
struct LaunchResult: Codable, Equatable, Identifiable, Hashable {
    
    let id: String
    let url: String
    let name: String
    let slug: String
    let status: LaunchStatus
    let lastUpdated, net: String?
    let windowEnd, windowStart: String?
    let image: LaunchImage?
    
    /// Converts the `net` string (ISO8601) into a formatted date string (dd.MM.yyyy).
    var netString: String? {
        guard let net else { return nil }
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        return date?.string(format: .ddMMYYYY)
    }
    
    /// Converts the `net` string into a `Date` object.
    var netDate: Date? {
        guard let net else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: net)
    }
    
    /// Extracts formatted name components.
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
    }
    
    // MARK: - Hashable & Equatable
    
    static func == (lhs: LaunchResult, rhs: LaunchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - LaunchResult Mock Data

extension LaunchResult {
    
    /// Generates a mock launch result for testing or previews.
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

// MARK: - LaunchStatus Enum

/// Describes the launch status with associated metadata for display.
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
    
    /// Full localized status name.
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
    
    /// Abbreviated localized status name.
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
    
    /// Color associated with each status for UI display.
    var color: Color {
        switch self {
        case .goForLaunch: return Color.App.Status.go
        case .toBeDetermined: return Color.App.Status.tbd
        case .launchSuccessful: return Color.App.Status.success
        case .launchFailure: return Color.App.Status.failure
        case .onHold: return Color.App.Status.hold
        case .inFlight: return Color.App.Status.flight
        case .partialFailure: return Color.App.Status.pFailure
        case .toBeConfirmed: return Color.App.Status.tbc
        case .payloadDeployed: return Color.App.Status.deployed
        case .unknown: return Color.secondary
        }
    }
    
    // MARK: - Codable conformance
    
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

// MARK: - FormattedNameModel

/// Parses the launch name into separate `name` and `mission` components.
struct FormattedNameModel {
    
    let name: String
    let mission: String
    
    /// Initializes by splitting on `" | "` delimiter.
    init(name: String) {
        let components = name.components(separatedBy: " | ")
        self.name = components.first ?? "-"
        self.mission = components.last ?? "-"
    }
}

// MARK: - LaunchImage Model

/// Contains URLs for the launch's image and thumbnail.
struct LaunchImage: Codable, Equatable {
    
    let imageUrl: String
    let thumbnailUrl: String
    
    /// Returns the full image URL.
    var imageBigUrl: URL? {
        URL(string: imageUrl)
    }
    
    /// Returns the thumbnail image URL.
    var imageThumbnailUrl: URL? {
        URL(string: thumbnailUrl)
    }
}

