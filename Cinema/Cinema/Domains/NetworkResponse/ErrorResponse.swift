//
//  ErrorResponse.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation

public enum ErrorResponseCode: String, Decodable {
    case notConnectedToInternet = "00000"
    case serviceDown = "00001"
    case genericError = "00002"
    case serverError = "00003"
    case sessionTimeout = "00004"
}

public struct ErrorResponse: Codable, Error {
    public let code: String
    public let title: String
    public let message: String

    public init(code: String, title: String, message: String) {
        self.code = code
        self.title = title
        self.message = message
    }
    
    public static func genericError() -> ErrorResponse {
        return ErrorResponse(code: ErrorResponseCode.genericError.rawValue,
                             title: "L10n.foundationGeneralUnableToProceedTitle",
                             message: "L10n.foundationGeneralUnableToProceedMessage")
    }

    public static func serverConnectionError() -> ErrorResponse {
        return ErrorResponse(code: ErrorResponseCode.serverError.rawValue,
                             title: "L10n.foundationGeneralUnableToProceedTitle",
                             message: "L10n.foundationGeneralUnableToProceedMessage")
    }

    public static func notConnectedToInternet() -> ErrorResponse {
        return ErrorResponse(code: ErrorResponseCode.notConnectedToInternet.rawValue,
                             title: "L10n.foundationGeneralNoInternetConnectionTitle",
                             message: "L10n.foundationGeneralNoInternetConnectionMessage")
    }
}

