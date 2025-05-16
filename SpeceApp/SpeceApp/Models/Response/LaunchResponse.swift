//
//  File.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation

struct LaunchResponse: Codable, Equatable {

    var launches: [Launch]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var launches = [Launch]()
        while !container.isAtEnd {
            let launch = try container.decode(Launch.self)
            launches.append(launch)
        }
        self.launches = launches
    }
}

//TODO: snake case opitmization

struct Launch: Codable, Equatable, Identifiable {
    
    static func == (lhs: Launch, rhs: Launch) -> Bool {
        lhs.flightNumber == rhs.flightNumber
    }
    
    var id: Int { flightNumber }
    
    let flightNumber: Int
    let missionName: String
    let launchYear: String
    let launchDateUTC: String
    let launchSuccess: Bool?
    let details: String?
    let links: Links
    let launchSite: LaunchSite
    let rocket: Rocket
    let launchFailureDetails: LaunchFailureDetails?

    enum CodingKeys: String, CodingKey {
        case flightNumber = "flight_number"
        case missionName = "mission_name"
        case launchYear = "launch_year"
        case launchDateUTC = "launch_date_utc"
        case launchSuccess = "launch_success"
        case details
        case links
        case launchSite = "launch_site"
        case rocket
        case launchFailureDetails = "launch_failure_details"
    }
}

struct Links: Codable {
    let missionPatch: String?
    let articleLink: String?

    enum CodingKeys: String, CodingKey {
        case missionPatch = "mission_patch"
        case articleLink = "article_link"
    }
}

struct LaunchSite: Codable {
    let siteID: String
    let siteName: String

    enum CodingKeys: String, CodingKey {
        case siteID = "site_id"
        case siteName = "site_name"
    }
}

struct Rocket: Codable {
    let rocketName: String
    let rocketType: String

    enum CodingKeys: String, CodingKey {
        case rocketName = "rocket_name"
        case rocketType = "rocket_type"
    }
}

struct LaunchFailureDetails: Codable {
    let time: Int
    let reason: String
}
