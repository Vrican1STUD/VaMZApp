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
        return request(params.url(id: id), method: params.method, parameters: params.parameters, encoding: params.encoding)
    }
    func requestReplaceURL(url: URL, params: SpaceX) -> DataRequest {
        return request(url, method: params.method, parameters: params.parameters, encoding: params.encoding)
    }
}

import RxSwift
extension DataRequest {
    
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
}

final class RequestManager {
    
    static let shared = RequestManager()
    
    private let session = AF
    
    func fetchLaunches(search: String?) -> Observable<LaunchResponse> {
        session.request(params: .launch(search: search)).processRx()
    }
    
    func paginate(url: URL, search: String?) -> Observable<LaunchResponse> {
        session.requestReplaceURL(url: url, params: .launch(search: search)).processRx()
    }
    
    func fetchDetailOfLaunch(id: String) -> Observable<LaunchDetailResult> {
        session.request(params: .detail, id: id).processRx()
    }
}

enum AppError: Error {
    case af(AFError)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .af(let error):
            error.underlyingError?.localizedDescription ?? error.localizedDescription
        case .unknown:
            String(localized: "request.error")
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

