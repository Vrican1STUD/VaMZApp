//
//  RequestManager.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire
import Combine

struct Paginacia: Encodable {
    
}

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
    func process<T: Decodable>() async throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try await self.serializingDecodable(T.self, decoder: decoder).value
    }
    
    func processRx<T: Decodable>() -> Observable<T> {
        return Observable.create { observer in
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            self.responseDecodable(of: T.self, decoder: decoder) { response in
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
/*Minulá uprava - vraj je tam pomiešaný combine*/
//    func processRx<T: Decodable>() -> Observable<T> {
//            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//        
//        return self
//            .publishDecodable(type: T.self, decoder: decoder)
//                   .value()
//                   .mapError { AppError.af($0) } // <= hard-coded to AppError
//                   .asObservable()
//            
////            return Observable.create { [weak self] observer in
////                guard let self = self else {
////                    observer.onCompleted()
////                    return Disposables.create()
////                }
////                
////                self.responseDecodable(of: T.self, decoder: decoder) { response in
////                    switch response.result {
////                    case .success(let data):
////                        observer.onNext(data)
////                        observer.onCompleted()
////                    case .failure(let error):
////                        observer.onError(AppError.af(error))
////                    }
////                }
////                
////                return Disposables.create()
////            }
//    }
}

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let session = AF
    
    func fetchLaunches() async throws -> LaunchResponse {
        return try await session.request(params: .countdown).process()
    }
    
    func fetchLaunches2() -> Observable<Upcoming> {
        session.request(params: .upcoming).processRx()
    }
    
    func fetchDetailOfLaunch(id: String) async throws -> LaunchDetailResult {
        do {
            return try await session.request(params: .upcoming, id: id).process()
        } catch {
            if let afError = error.asAFError {
                throw AppError.af(afError)
            } else {
                throw error
            }
        }
    }
    
    
    
    func fetchLaunchDetail(id: String) -> AnyPublisher<LaunchDetailResult, AppError> {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session
            .request(params: .upcoming, id: id)
            .publishDecodable(type: LaunchDetailResult.self, decoder: decoder)
            .value() // extracts the decoded value
            .mapError { 
                print("🚀: \($0)")
                return AppError.af($0) }
            .eraseToAnyPublisher()
    }
    
    func fetchUpcomingLaunches() async throws -> Upcoming {
        do {
            return try await session.request(params: .upcoming).process()
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
