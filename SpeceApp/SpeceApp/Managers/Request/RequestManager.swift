//
//  RequestManager.swift
//  SpeceApp
//
//  Created by Ja on 05/04/2025.
//

import Foundation
import Alamofire
import Combine

// MARK: - Session Extension for SpaceX Requests

/// Extension to `Session` (Alamofire) that simplifies request construction based on SpaceX enum.
extension Session {
    
    /// Performs a request using a parameter from the `SpaceX` enum and optional ID.
    /// - Parameters:
    ///   - params: SpaceX endpoint definition.
    ///   - id: Optional identifier for detail requests.
    /// - Returns: Alamofire `DataRequest` object.
    func request(params: SpaceX, id: String? = nil) -> DataRequest {
        return request(params.url(id: id), method: params.method, parameters: params.parameters, encoding: params.encoding)
    }
    
    /// Performs a request with a manually specified URL and parameters.
    /// - Parameters:
    ///   - url: Full endpoint URL.
    ///   - params: Parameters and method for the request.
    /// - Returns: Alamofire `DataRequest` object.
    func requestReplaceURL(url: URL, params: SpaceX) -> DataRequest {
        return request(url, method: params.method, parameters: params.parameters, encoding: params.encoding)
    }
}

import RxSwift

// MARK: - DataRequest Extension for RxSwift Integration

/// Extension for converting Alamofire's `DataRequest` into a reactive RxSwift Observable.
extension DataRequest {
    
    /// Processes a network response and emits decoded result as an Observable.
    /// - Returns: Observable stream of decoded response object.
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

// MARK: - RequestManager: Singleton API Client

/// Singleton manager responsible for handling SpaceX API requests.
final class RequestManager {
    
    /// Shared instance of the request manager.
    static let shared = RequestManager()
    
    /// Alamofire session (default).
    private let session = AF
    
    // MARK: API Methods
    
    /// Fetches a paginated list of launches, optionally filtered by search term.
    /// - Parameter search: Optional search keyword.
    /// - Returns: Observable with `LaunchResponse`.
    func fetchLaunches(search: String?) -> Observable<LaunchResponse> {
        session.request(params: .launch(search: search)).processRx()
    }
    
    /// Fetches the next page of launches from a given pagination URL.
    /// - Parameters:
    ///   - url: URL of the next page.
    ///   - search: Optional search keyword (if needed for backend).
    /// - Returns: Observable with `LaunchResponse`.
    func paginate(url: URL, search: String?) -> Observable<LaunchResponse> {
        session.requestReplaceURL(url: url, params: .launch(search: search)).processRx()
    }
    
    // Fetches detailed information about a specific launch.
    /// - Parameter id: ID of the launch.
    /// - Returns: Observable with `LaunchDetailResult`.
    func fetchDetailOfLaunch(id: String) -> Observable<LaunchDetailResult> {
        session.request(params: .detail, id: id).processRx()
    }
}

// MARK: - AppError: Application Request Errors

/// Custom application-level error wrapper.
enum AppError: Error {
    case af(AFError)
    case unknown
    
    /// Localized string describing the error.
    var localizedDescription: String {
        switch self {
        case .af(let error):
            error.underlyingError?.localizedDescription ?? error.localizedDescription
        case .unknown:
            String(localized: "request.error")
        }
    }
}

// MARK: - FetchingState: Asynchronous Operation State

/// Represents a state of an asynchronous fetch operation.
enum FetchingState<T: Equatable, E: Error> {
    case loading
    case idle
    case success(T)
    case error(E)
    
    /// The successful value if present.
    var successValue: T? {
        switch self {
        case .success(let value): value
        default: nil
        }
    }
    
    /// Indicates whether the state represents success.
    var isSuccess: Bool {
        switch self {
        case .success: true
        default: false
        }
    }
}

