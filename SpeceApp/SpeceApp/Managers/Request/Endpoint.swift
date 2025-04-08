//
//  Endpoint.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire

enum SpaceX {
    
    case launch(Encodable)
    case countdown
    case upcoming
    
    var path: String {
        switch self {
        case .countdown: "/v3/launches"
        case .launch: ""
        case .upcoming: "/2.3.0/launches/upcoming/"
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: Parameters? {
        switch self {
//        case .upcoming:
//            ["format": "json"]
        default: nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
//        case .upcoming:
//            URLEncoding.default
        default:
            JSONEncoding.default
        }
    }
    
    func url() -> URL {
//        URL(string: "https://api.spacexdata.com\(path)")!
        var url = URL(string: "https://ll.thespacedevs.com\(path)")!
//        ["format": "json"]
        url.append(queryItems: [.init(name: "format", value: "json")])
        print(url.absoluteString)
        return url
    }
}
