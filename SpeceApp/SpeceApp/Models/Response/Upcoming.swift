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

struct LaunchResult: Codable, Equatable, Identifiable, Hashable {
    
    let id: String
    let url: String
    let name: String
    let slug: String
    //    let launchDesignator: JSONNull?
    //    let status: NetPrecision
    let lastUpdated, net: String?
    //    let netPrecision: NetPrecision
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
    
    // Needed for Hashable
    static func == (lhs: LaunchResult, rhs: LaunchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var formattedNameModel: FormattedNameModel {
        .init(name: name)
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
