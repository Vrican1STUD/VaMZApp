//
//  Endpoint.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire

// MARK: - SpaceX API Endpoint Definition

/// Represents SpaceX API endpoints with parameters for requests.
enum SpaceX {
    
    /// API endpoint cases
    case launch(search: String?)
    case detail
    
    // MARK: - URL Path
    
    /// Returns the relative path for each API endpoint.
    var path: String {
        switch self {
        case .launch:
            return "/2.3.0/launches/"
        case .detail:
            return "/2.3.0/launches/"
        }
    }
    
    // MARK: - HTTP Method
    
    /// The HTTP method to be used for the request.
    var method: HTTPMethod {
        return .get
    }
    
    // MARK: - Request Parameters
    
    /// The parameters to be sent with the request.
    var parameters: Parameters? {
        var params: Parameters = [
            "format": "json"
        ]
        
        switch self {
        case .launch(let search):
            params["mode"] = "list"
            
            if let search = search, !search.isEmpty {
                params["search"] = search
            }
        case .detail:
            break
        }
        
        return params
    }
    
    // MARK: - Parameter Encoding
    
    /// Defines the encoding style for parameters.
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    // MARK: - URL Construction
    
    /// Constructs the full URL for the API request, appending an optional ID for detail requests.
    /// - Parameter id: Optional ID to append to the URL path (e.g., for details).
    /// - Returns: Complete URL for the request.
    func url(id: String? = nil) -> URL {
        var url = URL(string: "https://lldev.thespacedevs.com\(path)")!
        
        if let id = id {
            url.appendPathComponent(id + "/")
        }
        
        return url
    }
}

