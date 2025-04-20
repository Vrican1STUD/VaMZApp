//
//  RequestManager.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire

struct Paginacia: Encodable {
    
}

extension Session {
    func request(params: SpaceX) -> DataRequest {
        return request(params.url(), method: params.method, parameters: params.parameters, encoding: JSONEncoding.default)
    }
    func requestReplaceURL(url: URL, params: SpaceX) -> DataRequest {
        return request(url, method: params.method, parameters: params.parameters, encoding: JSONEncoding.default)
    }
}

extension DataRequest {
    func process<T: Decodable>() async throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await self.serializingDecodable(T.self, decoder: decoder).value
    }
}

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let session = AF
    
    func fetchLaunches() async throws -> LaunchResponse {
        return try await session.request(params: .countdown).process()
    }
    
    func fetchUpcomingLaunches() async throws -> Upcoming {
        do {
            return try await session.request(params: .upcoming)
                .process()
        } catch {
            if let afError = error.asAFError {
                throw AppError.af(afError)
            } else {
                throw error
            }
        }
    }
    func paginate(url: URL) async throws -> Upcoming {
        do {
            return try await session.requestReplaceURL(url: url, params: .upcoming)
                .process()
        } catch {
            if let afError = error.asAFError {
                throw AppError.af(afError)
            } else {
                throw error
            }
        }
    }
}

enum AppError: Error {
    case af(AFError)
    case internetConnection
    case serializationError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .af(let error):
            error.underlyingError?.localizedDescription ?? error.localizedDescription
            
        case .internetConnection:
            "Chyba"
        case .serializationError:
            "Dalsia Chyba"
        case .unknown:
            "Nechapem"
        }
    }
}
