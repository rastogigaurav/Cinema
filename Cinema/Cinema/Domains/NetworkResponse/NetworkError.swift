//
//  NetworkError.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation

public enum NetworkError: Error {
    /// Unknown or not supported error.
    case unknown

    /// Not connected to the internet.
    case notConnectedToInternet

    /// International data roaming turned off.
    case internationalRoamingOff

    /// Cannot reach the server.
    case notReachedServer

    /// Connection is lost.
    case connectionLost

    /// Incorrect data returned from the server.
    case incorrectDataReturned

    /// Connection is insecure
    case insecureConnection

    case cancelled

    /// Connected to Gateway, but dont have response from BE
    case serviceUnavailable

    /// empty response {}
    case emptyResponse

    case softError(error: ServerError?)
    
    public var message: String {
        switch self {
        case .incorrectDataReturned:
            return "Incorrect JSON format"
        case .softError(let error):
            return error?.message ?? "Something went wrong"
        case .notConnectedToInternet:
            return "You are offline"
        case .notReachedServer:
            return "Server not found"
        case .connectionLost:
            return "Connection lost"
        case .insecureConnection:
            return "Insecure connection"
        case .cancelled:
            return "Request Cancelled"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .emptyResponse:
            return "Empty Response"
        default:
            return "Unknown error"
        }
    }

    public var softErrorResponse: ServerError? {
        switch self {
        case .softError(let errorResponse):
            return errorResponse
        default:
            return nil
        }
    }
    
    public init(error: NSError) {
        switch error.domain {
        case NSURLErrorDomain:
            switch error.code {
            case NSURLErrorCancelled:
                self = .cancelled
            case NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost, NSURLErrorTimedOut, NSURLErrorDNSLookupFailed:
                self = .notReachedServer
            case NSURLErrorNetworkConnectionLost:
                self = .connectionLost
            case NSURLErrorNotConnectedToInternet:
                self = .notConnectedToInternet
            case NSURLErrorRedirectToNonExistentLocation, NSURLErrorBadServerResponse, NSURLErrorZeroByteResource, NSURLErrorCannotDecodeRawData, NSURLErrorCannotDecodeContentData,
                 NSURLErrorCannotParseResponse, NSURLErrorBadURL, NSURLErrorFileDoesNotExist, NSURLErrorFileIsDirectory, NSURLErrorResourceUnavailable,
                 NSURLErrorDataLengthExceedsMaximum, NSURLErrorUnsupportedURL:
                self = .incorrectDataReturned
            case NSURLErrorInternationalRoamingOff:
                self = .internationalRoamingOff
            default:
                self = .unknown
            }
        case String(kCFErrorDomainCFNetwork):
            switch error.code {
            case
            Int(CFNetworkErrors.cfurlErrorServerCertificateNotYetValid.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateUntrusted.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateHasBadDate.rawValue),
            Int(CFNetworkErrors.cfurlErrorServerCertificateHasUnknownRoot.rawValue),
            Int(CFNetworkErrors.cfurlErrorClientCertificateRejected.rawValue),
            Int(CFNetworkErrors.cfurlErrorClientCertificateRequired.rawValue),
            Int(CFNetworkErrors.cfErrorHTTPSProxyConnectionFailure.rawValue),
            Int(CFNetworkErrors.cfurlErrorSecureConnectionFailed.rawValue),
            Int(CFNetworkErrors.cfurlErrorCannotLoadFromNetwork.rawValue),
            Int(CFNetworkErrors.cfurlErrorCancelled.rawValue):
                self = .insecureConnection
            case Int(CFNetworkErrors.cfurlErrorNotConnectedToInternet.rawValue):
                self = .notConnectedToInternet
            default:
                self = .unknown
            }
        default:
            self = .unknown
        }
    }

    public func getErrorResponse() -> ServerError {
        switch self {
        case .softError(let errorResponse):
            return errorResponse ?? .genericError()
        case .serviceUnavailable:
            return .serverConnectionError()
        default:
            return .genericError()
        }
    }
}
