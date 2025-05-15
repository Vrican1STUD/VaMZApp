//
//  RequestManager.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire
import Combine

extension Session {
    func request(params: SpaceX, id: String? = nil) -> DataRequest {
        var url = params.url()
        if let iD = id {
            url.appendPathComponent(iD + "/")
        }
        return request(url, method: params.method, parameters: params.parameters, encoding: JSONEncoding.default)
    }
    func requestReplaceURL(url: URL, params: SpaceX) -> DataRequest {
        return request(url, method: params.method, parameters: params.parameters, encoding: JSONEncoding.default)
    }
}
import RxSwift
extension DataRequest {
//    func process<T: Decodable>() async throws -> T {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return try await self.serializingDecodable(T.self, decoder: decoder).value
//    }
    
    func processRx<T: Decodable>() -> Observable<T> {
        return Observable.create { observer in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            self.responseDecodable(of: T.self, decoder: decoder) { response in
//                print(response)
                switch response.result {
                case .success(let value):
                    observer.onNext(value)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(AppError.af(error))
                }
            }
            
            return Disposables.create()
        }
    }
}

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let session = AF
    
    func fetchLaunches() -> Observable<Upcoming> {
        session.request(params: .upcoming).processRx()
    }
    
    func paginate(url: URL) -> Observable<Upcoming> {
        session.requestReplaceURL(url: url, params: .upcoming).processRx()
    }
    
    func fetchDetailOfLaunch(id: String) -> Observable<LaunchDetailResult> {
        session.request(params: .upcoming, id: id).processRx()
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

enum FetchingState<T: Equatable, E: Error> {
    case loading
    case idle
    case success(T)
    case error(E)
    
    var successValue: T? {
        switch self {
        case .success(let value): value
        default: nil
        }
    }
    
    var isSuccess: Bool {
        switch self {
        case .success: true
        default: false
        }
    }
}
