//
//  NetworkClient.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Moya
import Alamofire
import RxSwift
import Reachability

struct StubResponse {
    let responseCode: Int
    let responseData: Data
}

struct SubStatusCode: Decodable {
    var code: ServerErrorCode?
}

typealias NRResultResponseCompletion<T> = ((NRResult<T>, Response?, Int?, ServerErrorCode) -> Void)

struct NetworkClient {
    public static var shared = NetworkClient(stubResponse: nil)
    private let reachability = ReachabilityClient()
    fileprivate var provider: MoyaProvider<MultiTarget>
    static var grantAPIRunning = false
    init(stubResponse: StubResponse?) {
        if let stub = stubResponse {
            let errorEndpoint = {(target: MultiTarget) -> Endpoint in
                var data: Data!
                if(200...500).contains(stubResponse!.responseCode) {
                    data = stub.responseData
                } else {
                    data = target.sampleData
                }

                return Endpoint(url: URL(target: target).absoluteString,
                                sampleResponseClosure: { .networkResponse(stub.responseCode, data)},
                                method: target.method,
                                task: target.task,
                                httpHeaderFields: target.headers)
            }
            self.provider = MoyaProvider<MultiTarget>(endpointClosure: errorEndpoint, stubClosure: MoyaProvider.immediatelyStub)
        } else {
            var trustManagerEvaluators = [String : ServerTrustEvaluating]()
            
            if let baseUrlHost = URL(string: AppContext.instance.infoForKey(ConfigKeys.baseUrl.rawValue,
                                                                         defaultValue: ""))?.host {
                trustManagerEvaluators[baseUrlHost] = DisabledTrustEvaluator()
            }
            let manager = Session(
                configuration: URLSessionConfiguration.default,
                serverTrustManager: ServerTrustManager(evaluators: trustManagerEvaluators)
            )
            self.provider = MoyaProvider<MultiTarget>(
                requestClosure: { (endpoint, closure) in
                    //NetworkClient.shared.interceptRequest(with: endpoint, and: closure)
                },
                stubClosure: { (_) -> StubBehavior in
                    return .never
                }, session: manager)
        }
    }
}

// MARK: - Extension NetworkClient
/**
 - parameters:
 - T: TargetTypex
 */

extension Response {
    func parseTo<T: Decodable>(_ type: T.Type) -> T? {
            return try? self.map(T.self)
    }
}

extension NetworkClient {

    func handleMoyaResult<T: Decodable>(result: Result<Moya.Response, MoyaError>,
                                        completion: @escaping (Result<T, NetworkError>) -> Void) {
        switch result {
        case .success(let value):
            do {
                let filteredResponse = try value.filterSuccessfulStatusCodes()
                let result = try filteredResponse.map(T.self)
                completion(.success(result))
            } catch is DecodingError {
                completion(.failure(NetworkError.incorrectDataReturned))
            } catch MoyaError.statusCode(let response) {
                let error = moyaError(response: response, value: value)
                completion(.failure(error))
            } catch {
                if (try? value.map(EmptyResponse.self)) != nil {
                    completion(.failure(NetworkError.emptyResponse))
                } else {
                    completion(.failure(NetworkError.unknown))
                }
            }
        case .failure(let error):
            let error = handleFailure(error: error)
            completion(.failure(error))
        }
    }

    func handleMoyaImageResult(result: Result<Moya.Response, MoyaError>,
                               completion: @escaping (Result<Image, NetworkError>) -> Void) {
        switch result {
        case .success(let value):
            do {
                let image = try value.mapImage()
                completion(.success(image))
            } catch MoyaError.statusCode(let response) {
                let error = moyaError(response: response, value: value)
                completion(.failure(error))
            } catch {
                completion(.failure(NetworkError.unknown))
            }
        case .failure(let error):
            let error = handleFailure(error: error)
            completion(.failure(error))
        }
    }

    private func moyaError(response: Moya.Response, value: Moya.Response) -> NetworkError {
        if response.statusCode == HTTPStatusCode.serviceUnavailable.rawValue {
            do {
                let result = try value.map(ServerError.self)
                if result.title != "", result.message != "" {
                    return NetworkError.softError(error: result)
                } else {
                    return NetworkError.serviceUnavailable
                }
            } catch {
                return NetworkError.serviceUnavailable
            }
        } else {
            do {
                let result = try value.map(ServerError.self)
                return NetworkError.softError(error: result)
            } catch {
                return NetworkError.incorrectDataReturned
            }
        }
    }

    private func handleFailure(error: MoyaError) -> NetworkError {
        switch error {
        case .underlying(let error, _):
            return NetworkError(error: error as NSError)
        default:
            do {
                let result = try error.response?.map(ServerError.self)
                let softError = NetworkError.softError(error: result)

                return softError
            } catch {
                return NetworkError.incorrectDataReturned
            }
        }
    }

    func requestObject<T: TargetType, C: Decodable>(_ target: T, c classType: C.Type, completion: @escaping (Result<C, NetworkError>) -> Void) {
        URLCache.shared.removeAllCachedResponses()
        provider.request(MultiTarget(target)) { (responseResult) in
            if self.reachability.currentConnectionStatus() == Reachability.Connection.unavailable {
                let errorResponse = ServerError.notConnectedToInternet()
                completion(.failure(NetworkError.softError(error: errorResponse)))
                return
            }
            handleMoyaResult(result: responseResult, completion: completion)

        }
    }

    func responseObject<T: Decodable>(for requestType: TargetType,
                                    completion: @escaping NRResultCompletion<T>) {
            provider.request(MultiTarget(requestType)) { (responseResult) in
            if self.reachability.currentConnectionStatus() == Reachability.Connection.unavailable {
                let errorResponse = ServerError.notConnectedToInternet()
                completion(.failure(NetworkError.softError(error: errorResponse)))
                return
            }
            handleMoyaResult(result: responseResult) { (result: Result<T, NetworkError>) in
                switch result {
                case let .success(value):
                    completion(.success(value))
                case let .failure(error):
                    completion(.failure(error))
                }
            }
        }
    }
    func responseObject<T: Decodable>(for requestType: TargetType,
                                    completion: @escaping NRResultResponseCompletion<T>) {
         provider.request(MultiTarget(requestType)) { (responseResult) in
            if self.reachability.currentConnectionStatus() == Reachability.Connection.unavailable {
                let errorResponse = ServerError.notConnectedToInternet()
                completion(.failure(NetworkError.softError(error: errorResponse)), nil, nil, .none)
                return
            }
            let response: Response? = responseResult.success
            let code: Int? = responseResult.success?.statusCode ?? nil
            let subStatusCode: ServerErrorCode = response?.parseTo(SubStatusCode.self)?.code ?? .none
            handleMoyaResult(result: responseResult) { (result: Result<T, NetworkError>) in
                switch result {
                case let .success(value):
                    completion(.success(value), response, code, subStatusCode)
                case let .failure(error):
                    completion(.failure(error), response, code, subStatusCode)
                }
            }
        }
    }

    func requestImage(_ target: TargetType, completion: @escaping (Result<Image, NetworkError>) -> Void) {
        provider.request(MultiTarget(target)) { result in
            handleMoyaImageResult(result: result, completion: completion)
        }
    }
}

