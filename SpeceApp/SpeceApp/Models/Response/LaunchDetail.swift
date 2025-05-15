//
//  Detail.swift
//  SpeceApp
//
//  Created by Ja on 22/04/2025.
//

import Foundation
import SwiftUI
import MapKit

// MARK: - Upcoming
struct LaunchDetailResult: Decodable, Equatable, Identifiable {
    
    let id: String
    let url: String
    let name, /*responseMode,*/ slug: String
    //    let launchDesignator: JSONNull?
    //    let status: NetPrecision
    let net: String?
    //    let netPrecision: NetPrecision
    //    let windowEnd, windowStart: Date
    let image: LaunchImage
    //    let failreason: String
    //    let hashtag: JSONNull?
    //    let launchServiceProvider: LaunchServiceProvider
    let rocket: DetailRocket
    //    let mission: Mission
    let pad: Pad
    //    let webcastLive: Bool
    //    let program: [JSONAny]
    //    let orbitalLaunchAttemptCount, locationLaunchAttemptCount, padLaunchAttemptCount, agencyLaunchAttemptCount: Int
    //    let orbitalLaunchAttemptCountYear, locationLaunchAttemptCountYear, padLaunchAttemptCountYear, agencyLaunchAttemptCountYear: Int
    //    let flightclubURL: JSONNull?
    //    let updates: [Update]
    //    let infoUrls: [InfoURL]
    let vidUrls: [VidURL]
    //    let timeline: [JSONAny]
    //    let padTurnaround: String
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
    }
    
    var socailMediaUrls : SocialLinksModel {
        .init(wikiUrl: rocket.configuration.wikiUrl, vidUrls: vidUrls)
    }
    ////    let missionPatches: [MissionPatch]
    ///
    var netDate: Date? {
        guard let net else { return nil }
        
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: net)
        
        return date
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

//// MARK: - Variant
//struct Variant: Codable {
//    let id: Int
//    let type: TypeClass
//    let imageURL: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, type
//        case imageURL = "image_url"
//    }
//}
//
//// MARK: - TypeClass
//struct TypeClass: Codable {
//    let id: Int
//    let name: String
//}
//
//// MARK: - LaunchServiceProvider
//struct LaunchServiceProvider: Codable {
//    let responseMode: String
//    let id: Int
//    let url: String
//    let name, abbrev: String
//    let type: TypeClass
//    let featured: Bool
//    let country: [Country]
//    let description, administrator: String
//    let foundingYear: Int
//    let launchers, spacecraft: String
//    let parent: String?
//    let image, logo, socialLogo: Image
//    let totalLaunchCount, consecutiveSuccessfulLaunches, successfulLaunches, failedLaunches: Int
//    let pendingLaunches, consecutiveSuccessfulLandings, successfulLandings, failedLandings: Int
//    let attemptedLandings, successfulLandingsSpacecraft, failedLandingsSpacecraft, attemptedLandingsSpacecraft: Int
//    let successfulLandingsPayload, failedLandingsPayload, attemptedLandingsPayload: Int
//    let infoURL, wikiURL: String
//    let socialMediaLinks: [SocialMediaLink]
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, url, name, abbrev, type, featured, country, description, administrator
//        case foundingYear = "founding_year"
//        case launchers, spacecraft, parent, image, logo
//        case socialLogo = "social_logo"
//        case totalLaunchCount = "total_launch_count"
//        case consecutiveSuccessfulLaunches = "consecutive_successful_launches"
//        case successfulLaunches = "successful_launches"
//        case failedLaunches = "failed_launches"
//        case pendingLaunches = "pending_launches"
//        case consecutiveSuccessfulLandings = "consecutive_successful_landings"
//        case successfulLandings = "successful_landings"
//        case failedLandings = "failed_landings"
//        case attemptedLandings = "attempted_landings"
//        case successfulLandingsSpacecraft = "successful_landings_spacecraft"
//        case failedLandingsSpacecraft = "failed_landings_spacecraft"
//        case attemptedLandingsSpacecraft = "attempted_landings_spacecraft"
//        case successfulLandingsPayload = "successful_landings_payload"
//        case failedLandingsPayload = "failed_landings_payload"
//        case attemptedLandingsPayload = "attempted_landings_payload"
//        case infoURL = "info_url"
//        case wikiURL = "wiki_url"
//        case socialMediaLinks = "social_media_links"
//    }
//}
//
//// MARK: - Country
//struct Country: Codable {
//    let id: Int
//    let name, alpha2_Code, alpha3_Code, nationalityName: String
//    let nationalityNameComposed: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, name
//        case alpha2_Code = "alpha_2_code"
//        case alpha3_Code = "alpha_3_code"
//        case nationalityName = "nationality_name"
//        case nationalityNameComposed = "nationality_name_composed"
//    }
//}
//
//// MARK: - SocialMediaLink
//struct SocialMediaLink: Codable {
//    let id: Int
//    let socialMedia: SocialMedia
//    let url: String
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case socialMedia = "social_media"
//        case url
//    }
//}
//
//// MARK: - SocialMedia
//struct SocialMedia: Codable {
//    let id: Int
//    let name: String
//    let url: String?
//    let logo: Image?
//}
//
//// MARK: - Mission
//struct Mission: Codable, Equatable {
////    let id: Int
////    let name, type, description: String
////    let image: Image
////    let orbit: NetPrecision
////    let agencies: [LaunchServiceProvider]
//    let infoUrls: [InfoURL]
//    let vidUrls: [VidURL]
//
////    enum CodingKeys: String, CodingKey {
////        case id, name, type, description, image, orbit, agencies
////        case infoUrls = "info_urls"
////        case vidUrls = "vid_urls"
////    }
//}
//
//// MARK: - InfoURL
struct InfoURL: Codable, Equatable {
//    let priority: Int
//    let source, title, description: String
//    let featureImage: JSONNull?
    let url: String
//    let type: TypeClass
//    let language: Language

}
//
//// MARK: - Language
//struct Language: Codable {
//    let id: Int
//    let name, code: String
//}
//
//// MARK: - NetPrecision
//struct NetPrecision: Codable {
//    let id: Int
//    let name, abbrev: String
//    let celestialBody: NetPrecisionCelestialBody?
//    let description: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, abbrev
//        case celestialBody = "celestial_body"
//        case description
//    }
//}
//
//// MARK: - NetPrecisionCelestialBody
//struct NetPrecisionCelestialBody: Codable {
//    let responseMode: String
//    let id: Int
//    let name: String
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, name
//    }
//}
//
//// MARK: - VidURL
struct VidURL: Codable, Equatable {
//    let priority: Int
//    let source, publisher, title, description: String
//    let featureImage: String
    let url: String
//    let type: TypeClass
//    let language: Language
//    let startTime, endTime: JSONNull?
//    let live: Bool
}
//
//// MARK: - MissionPatch
//struct MissionPatch: Codable {
//    let id: Int
//    let name: String
//    let priority: Int
//    let imageURL: String
//    let agency: MissionPatchAgency
//    let responseMode: String
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, priority
//        case imageURL = "image_url"
//        case agency
//        case responseMode = "response_mode"
//    }
//}
//
//// MARK: - MissionPatchAgency
//struct MissionPatchAgency: Codable {
//    let responseMode: String
//    let id: Int
//    let url: String
//    let name, abbrev: String
//    let type: TypeClass
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, url, name, abbrev, type
//    }
//}
//
// MARK: - Pad
struct Pad: Codable, Equatable {
//    let id: Int
//    let url: String
//    let active: Bool
//    let agencies: [AgencyElement]
    let name: String
//    let image: LaunchImage
    let description: String?
//    let infoURL: JSONNull?
//    let wikiURL, mapURL: String
    let latitude, longitude: Double
//    let country: Country
    let mapImage: String
//    let totalLaunchCount, orbitalLaunchAttemptCount: Int
//    let fastestTurnaround: String
//    let location: Location
}

//// MARK: - AgencyElement
//struct AgencyElement: Codable {
//    let responseMode: String
//    let id: Int
//    let url: String
//    let name, abbrev: String
//    let type: TypeClass
//    let featured: Bool
//    let country: [Country]
//    let description, administrator: String
//    let foundingYear: Int
//    let launchers, spacecraft, parent: String
//    let image, logo, socialLogo: Image
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, url, name, abbrev, type, featured, country, description, administrator
//        case foundingYear = "founding_year"
//        case launchers, spacecraft, parent, image, logo
//        case socialLogo = "social_logo"
//    }
//}
//
//// MARK: - Location
//struct Location: Codable {
//    let responseMode: String
//    let id: Int
//    let url: String
//    let name: String
//    let celestialBody: LocationCelestialBody
//    let active: Bool
//    let country: Country
//    let description: String
//    let image: Image
//    let mapImage: String
//    let longitude, latitude: Double
//    let timezoneName: String
//    let totalLaunchCount, totalLandingCount: Int
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, url, name
//        case celestialBody = "celestial_body"
//        case active, country, description, image
//        case mapImage = "map_image"
//        case longitude, latitude
//        case timezoneName = "timezone_name"
//        case totalLaunchCount = "total_launch_count"
//        case totalLandingCount = "total_landing_count"
//    }
//}
//
//// MARK: - LocationCelestialBody
//struct LocationCelestialBody: Codable {
//    let responseMode: String
//    let id: Int
//    let name: String
//    let type: TypeClass
//    let diameter: Int
//    let mass, gravity: Double
//    let lengthOfDay: String
//    let atmosphere: Bool
//    let image: Image
//    let description: String
//    let wikiURL: String
//    let totalAttemptedLaunches, successfulLaunches, failedLaunches, totalAttemptedLandings: Int
//    let successfulLandings, failedLandings: Int
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, name, type, diameter, mass, gravity
//        case lengthOfDay = "length_of_day"
//        case atmosphere, image, description
//        case wikiURL = "wiki_url"
//        case totalAttemptedLaunches = "total_attempted_launches"
//        case successfulLaunches = "successful_launches"
//        case failedLaunches = "failed_launches"
//        case totalAttemptedLandings = "total_attempted_landings"
//        case successfulLandings = "successful_landings"
//        case failedLandings = "failed_landings"
//    }
//}
//
// MARK: - Rocket
struct DetailRocket: Codable, Equatable {
    let id: Int
    let configuration: RocketConfiguration
//    let launcherStage, spacecraftStage: [JSONAny]
//    let payloads: [PayloadElement]
}

// MARK: - Configuration
struct RocketConfiguration: Codable, Equatable {
//    let responseMode: String
//    let id: Int
//    let url: String
    let name: String
////    let families: [Family]
//    let fullName, variant: String
//    let active, isPlaceholder: Bool
////    let manufacturer: LaunchServiceProvider
////    let program: [JSONAny]
    let reusable: Bool
////    let image: Image
//    let infoURL: String
    let wikiUrl: String?
    let description, alias: String
    let minStage, maxStage: Float?
    let length: Float?
    let diameter: Float?
//    let maidenFlight: String
    let launchCost: Float?
    let launchMass, leoCapacity: Float?
////    let gtoCapacity, geoCapacity: JSONNull?
//    let ssoCapacity, toThrust: Int
////    let apogee: JSONNull?
    let totalLaunchCount, consecutiveSuccessfulLaunches, successfulLaunches, failedLaunches: Float
    let pendingLaunches, attemptedLandings, successfulLandings, failedLandings: Float
//    let consecutiveSuccessfulLandings: Int
//    let fastestTurnaround: String
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

//// MARK: - Family
//struct Family: Codable {
//    let responseMode: String
//    let id: Int
//    let name: String
//    let manufacturer: [LaunchServiceProvider]
//    let parent: JSONNull?
//    let description: String
//    let active: Bool
//    let maidenFlight: String
//    let totalLaunchCount, consecutiveSuccessfulLaunches, successfulLaunches, failedLaunches: Int
//    let pendingLaunches, attemptedLandings, successfulLandings, failedLandings: Int
//    let consecutiveSuccessfulLandings: Int
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, name, manufacturer, parent, description, active
//        case maidenFlight = "maiden_flight"
//        case totalLaunchCount = "total_launch_count"
//        case consecutiveSuccessfulLaunches = "consecutive_successful_launches"
//        case successfulLaunches = "successful_launches"
//        case failedLaunches = "failed_launches"
//        case pendingLaunches = "pending_launches"
//        case attemptedLandings = "attempted_landings"
//        case successfulLandings = "successful_landings"
//        case failedLandings = "failed_landings"
//        case consecutiveSuccessfulLandings = "consecutive_successful_landings"
//    }
//}
//
//// MARK: - PayloadElement
//struct PayloadElement: Codable {
//    let responseMode: String
//    let id: Int
//    let url: String
//    let destination: String
//    let amount: Int
//    let payload: PayloadPayload
//    let landing: JSONNull?
//    let dockingEvents: [JSONAny]
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, url, destination, amount, payload, landing
//        case dockingEvents = "docking_events"
//    }
//}
//
//// MARK: - PayloadPayload
//struct PayloadPayload: Codable {
//    let responseMode: String
//    let id: Int
//    let name: String
//    let type: TypeClass
//    let manufacturer, payloadOperator: LaunchServiceProvider
//    let image: Image
//    let wikiLink, infoLink: String
//    let program: [JSONAny]
//    let cost, mass: Int
//    let description: String
//
//    enum CodingKeys: String, CodingKey {
//        case responseMode = "response_mode"
//        case id, name, type, manufacturer
//        case payloadOperator = "operator"
//        case image
//        case wikiLink = "wiki_link"
//        case infoLink = "info_link"
//        case program, cost, mass, description
//    }
//}
//
//// MARK: - Update
//struct Update: Codable {
//    let id: Int
//    let profileImage: String
//    let comment: String
//    let infoURL: String
//    let createdBy: String
//    let createdOn: Date
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case profileImage = "profile_image"
//        case comment
//        case infoURL = "info_url"
//        case createdBy = "created_by"
//        case createdOn = "created_on"
//    }
//}
//
//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//            return true
//    }
//
//    public var hashValue: Int {
//            return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//            let container = try decoder.singleValueContainer()
//            if !container.decodeNil() {
//                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//            }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//            var container = encoder.singleValueContainer()
//            try container.encodeNil()
//    }
//}
//
//class JSONCodingKey: CodingKey {
//    let key: String
//
//    required init?(intValue: Int) {
//            return nil
//    }
//
//    required init?(stringValue: String) {
//            key = stringValue
//    }
//
//    var intValue: Int? {
//            return nil
//    }
//
//    var stringValue: String {
//            return key
//    }
//}
//
//class JSONAny: Codable {
//
//    let value: Any
//
//    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
//            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
//            return DecodingError.typeMismatch(JSONAny.self, context)
//    }
//
//    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
//            let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
//            return EncodingError.invalidValue(value, context)
//    }
//
//    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
//            if let value = try? container.decode(Bool.self) {
//                    return value
//            }
//            if let value = try? container.decode(Int64.self) {
//                    return value
//            }
//            if let value = try? container.decode(Double.self) {
//                    return value
//            }
//            if let value = try? container.decode(String.self) {
//                    return value
//            }
//            if container.decodeNil() {
//                    return JSONNull()
//            }
//            throw decodingError(forCodingPath: container.codingPath)
//    }
//
//    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
//            if let value = try? container.decode(Bool.self) {
//                    return value
//            }
//            if let value = try? container.decode(Int64.self) {
//                    return value
//            }
//            if let value = try? container.decode(Double.self) {
//                    return value
//            }
//            if let value = try? container.decode(String.self) {
//                    return value
//            }
//            if let value = try? container.decodeNil() {
//                    if value {
//                            return JSONNull()
//                    }
//            }
//            if var container = try? container.nestedUnkeyedContainer() {
//                    return try decodeArray(from: &container)
//            }
//            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
//                    return try decodeDictionary(from: &container)
//            }
//            throw decodingError(forCodingPath: container.codingPath)
//    }
//
//    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
//            if let value = try? container.decode(Bool.self, forKey: key) {
//                    return value
//            }
//            if let value = try? container.decode(Int64.self, forKey: key) {
//                    return value
//            }
//            if let value = try? container.decode(Double.self, forKey: key) {
//                    return value
//            }
//            if let value = try? container.decode(String.self, forKey: key) {
//                    return value
//            }
//            if let value = try? container.decodeNil(forKey: key) {
//                    if value {
//                            return JSONNull()
//                    }
//            }
//            if var container = try? container.nestedUnkeyedContainer(forKey: key) {
//                    return try decodeArray(from: &container)
//            }
//            if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
//                    return try decodeDictionary(from: &container)
//            }
//            throw decodingError(forCodingPath: container.codingPath)
//    }
//
//    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
//            var arr: [Any] = []
//            while !container.isAtEnd {
//                    let value = try decode(from: &container)
//                    arr.append(value)
//            }
//            return arr
//    }
//
//    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
//            var dict = [String: Any]()
//            for key in container.allKeys {
//                    let value = try decode(from: &container, forKey: key)
//                    dict[key.stringValue] = value
//            }
//            return dict
//    }
//
//    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
//            for value in array {
//                    if let value = value as? Bool {
//                            try container.encode(value)
//                    } else if let value = value as? Int64 {
//                            try container.encode(value)
//                    } else if let value = value as? Double {
//                            try container.encode(value)
//                    } else if let value = value as? String {
//                            try container.encode(value)
//                    } else if value is JSONNull {
//                            try container.encodeNil()
//                    } else if let value = value as? [Any] {
//                            var container = container.nestedUnkeyedContainer()
//                            try encode(to: &container, array: value)
//                    } else if let value = value as? [String: Any] {
//                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
//                            try encode(to: &container, dictionary: value)
//                    } else {
//                            throw encodingError(forValue: value, codingPath: container.codingPath)
//                    }
//            }
//    }
//
//    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
//            for (key, value) in dictionary {
//                    let key = JSONCodingKey(stringValue: key)!
//                    if let value = value as? Bool {
//                            try container.encode(value, forKey: key)
//                    } else if let value = value as? Int64 {
//                            try container.encode(value, forKey: key)
//                    } else if let value = value as? Double {
//                            try container.encode(value, forKey: key)
//                    } else if let value = value as? String {
//                            try container.encode(value, forKey: key)
//                    } else if value is JSONNull {
//                            try container.encodeNil(forKey: key)
//                    } else if let value = value as? [Any] {
//                            var container = container.nestedUnkeyedContainer(forKey: key)
//                            try encode(to: &container, array: value)
//                    } else if let value = value as? [String: Any] {
//                            var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
//                            try encode(to: &container, dictionary: value)
//                    } else {
//                            throw encodingError(forValue: value, codingPath: container.codingPath)
//                    }
//            }
//    }
//
//    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
//            if let value = value as? Bool {
//                    try container.encode(value)
//            } else if let value = value as? Int64 {
//                    try container.encode(value)
//            } else if let value = value as? Double {
//                    try container.encode(value)
//            } else if let value = value as? String {
//                    try container.encode(value)
//            } else if value is JSONNull {
//                    try container.encodeNil()
//            } else {
//                    throw encodingError(forValue: value, codingPath: container.codingPath)
//            }
//    }
//
//    public required init(from decoder: Decoder) throws {
//            if var arrayContainer = try? decoder.unkeyedContainer() {
//                    self.value = try JSONAny.decodeArray(from: &arrayContainer)
//            } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
//                    self.value = try JSONAny.decodeDictionary(from: &container)
//            } else {
//                    let container = try decoder.singleValueContainer()
//                    self.value = try JSONAny.decode(from: container)
//            }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//            if let arr = self.value as? [Any] {
//                    var container = encoder.unkeyedContainer()
//                    try JSONAny.encode(to: &container, array: arr)
//            } else if let dict = self.value as? [String: Any] {
//                    var container = encoder.container(keyedBy: JSONCodingKey.self)
//                    try JSONAny.encode(to: &container, dictionary: dict)
//            } else {
//                    var container = encoder.singleValueContainer()
//                    try JSONAny.encode(to: &container, value: self.value)
//            }
//    }
//}

