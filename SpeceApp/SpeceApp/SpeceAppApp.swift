//
//  SpeceAppApp.swift
//  SpeceApp
//
//  Created by Peter on 12/03/2025.
//

import SwiftUI
import Alamofire

@main
struct SpeceAppApp: App {
    
    private let RM: RequestManager
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        RM = RequestManager()
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .task {
                    do {
                        let launches = try await RM.fetchLaunches()
                        print(launches)
                    } catch {
                        print("Error fetching launches: \(error)")
                    }
                }
        }
    }
    
}

struct Paginacia: Encodable {
    
}

enum SpaceX {
    
    case launch(Encodable)
    case countdown
    
    var path: String {
        switch self {
        case .countdown: "/v3/launches"
        case .launch: ""
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
//        switch self {
            
            JSONEncoding.default
//        }
    }
    
    func url() -> URL {
        URL(string: "https://api.spacexdata.com\(path)")!
    }
    
}

extension Session {
    
    func request(params: SpaceX) -> DataRequest {
        return request(params.url(), method: params.method, parameters: params.parameters, encoding: JSONEncoding.default)
    }
    
}

extension DataRequest {
    
    func process<T: Decodable>() async throws -> T {
        try await self.serializingDecodable(T.self).value
    }
    
}

final class RequestManager {
    
    private let session = AF
    
    func fetchLaunches() async throws -> LaunchResponse {
        return try await session.request(params: .countdown).process()
    }
}

enum AppError: Error {
    case internetConnection
    case serializationError
    case unknown
    
    var localizedDescription: String? {
        switch self {
            
        case .internetConnection:
            "Chyba"
        case .serializationError:
            "Dalsia Chyba"
        case .unknown:
            "Nechapem"
        }
    }
}


//

import UIKit

// MARK: - Launch Response Model

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

