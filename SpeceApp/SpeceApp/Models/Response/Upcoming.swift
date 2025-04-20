//
//  Upcoming.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation

struct Upcoming: Decodable, Equatable {
    let count: Int?
    let next: String?
    let results: [LaunchResult]
    
    var nextPagingUrl: URL? {
        guard let next, let url = URL(string: next) else { return nil }
        
        return url
    }
}

struct LaunchResult: Codable, Equatable, Identifiable {
    
    let id: String
    let url: String
    let name: String
//        let responseMode: LocationResponseMode
    let slug: String
    //    let launchDesignator: JSONNull?
    //    let status: NetPrecision
    let lastUpdated, net: String?
    //    let netPrecision: NetPrecision
    let windowEnd, windowStart: String?
    let image: LaunchImage?
    //    let infographic, probability, weatherConcerns: JSONNull?
    let failreason: String
    //    let hashtag: JSONNull?
    //    let launchServiceProvider: LaunchServiceProvider
    //    let rocket: Rocket
    //    let mission: Mission
    //    let pad: Pad
    let webcastLive: Bool
//        let program: [Program]
    let orbitalLaunchAttemptCount: Int?
//    locationLaunchAttemptCount, padLaunchAttemptCount, agencyLaunchAttemptCount: Int
//    let orbitalLaunchAttemptCountYear, locationLaunchAttemptCountYear, padLaunchAttemptCountYear, agencyLaunchAttemptCountYear: Int
    
    var netString: String? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date?.string(format: .ddMMYYYY)
    }
//
}

struct LaunchImage: Codable, Equatable {
    let thumbnailUrl: String
    
    var imageUrl: URL? {
        URL(string: thumbnailUrl)
    }
}
