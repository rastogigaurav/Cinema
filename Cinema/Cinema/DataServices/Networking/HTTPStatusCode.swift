//
//  HTTPStatusCode.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation

public enum HTTPStatusCode: Int {
    // 200 Success
    case success = 200
    case created
    case accepted
    case nonAuthoritativeInformation
    case noContent
    case resetContent
    case partialContent
    case multiStatus
    case alreadyReported
    case found
    case seeOther
    case notModified
    case useProxy
    case switchProxy
    case temporaryRedirect
    case permanentRedirect
    // 400 Client Error
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired
    case forbidden
    case notFound
    // 500 Server Error
    case internalServerError = 500
    case notImplemented
    case badGateway
    case serviceUnavailable
    case gatewayTimeout
    case httpVersionNotSupported
    case networkAuthenticationRequired
}

