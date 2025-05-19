//
//  Endpoint.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire

enum SpaceX {
    
    case launch(search: String?)
    case detail

    var path: String {
        switch self {
        case .launch:
            return "/2.3.0/launches/"
        case .detail:
            return "/2.3.0/launches/"
        }
    }

    var method: HTTPMethod {
        return .get
    }

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
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }

    func url(id: String? = nil) -> URL {
        var url = URL(string: "https://lldev.thespacedevs.com\(path)")!
        
        if let id = id {
            url.appendPathComponent(id + "/")
        }
        
        return url
    }
}

