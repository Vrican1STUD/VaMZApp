//
//  Upcoming.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation

struct Upcoming: Decodable {
    let count: Int
//    let next: String
    let results: [LaunchResult]
}

struct LaunchResult: Decodable {
    
    let id: String
    let url: String
    let name: String
//        let responseMode: LocationResponseMode
    let slug: String
    //    let launchDesignator: JSONNull?
    //    let status: NetPrecision
//    let lastUpdated, net: Date?
    //    let netPrecision: NetPrecision
//    let windowEnd, windowStart: Date?
    //    let image: Image
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
//    
}
