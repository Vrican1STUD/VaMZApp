//
//  Endpoint.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire

enum SpaceX {
    
    case upcoming
    
    var path: String {
        switch self {
        case .upcoming: "/2.3.0/launches/"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        switch self {
        default: nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            JSONEncoding.default
        }
    }
    
    func url() -> URL {
        var url = URL(string: "https://lldev.thespacedevs.com\(path)")!
//        ["format": "json"]
        url.append(queryItems: [.init(name: "format", value: "json")])
        url.append(queryItems: [.init(name: "mode", value: "list")])
//        url.append(queryItems: [.init(name: "search", value: "fal")])
        
//        print(url.absoluteString)
        return url
    }
}
