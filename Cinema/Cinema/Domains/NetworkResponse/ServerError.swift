//
//  ServerError.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation

public enum ServerErrorCode: String, Decodable {
    case notConnectedToInternet = "00000"
    case serviceDown = "00001"
    case genericError = "00002"
    case serverError = "00003"
    case sessionTimeout = "00004"
    case none = "None"
}

public struct ServerError: Codable, Error {
    public let code: String
    public let title: String
    public let message: String

    public init(code: String, title: String, message: String) {
        self.code = code
        self.title = title
        self.message = message
    }
    
    public static func genericError() -> ServerError {
        return ServerError(code: ServerErrorCode.genericError.rawValue,
                             title: "L10n.foundationGeneralUnableToProceedTitle",
                             message: "L10n.foundationGeneralUnableToProceedMessage")
    }

    public static func serverConnectionError() -> ServerError {
        return ServerError(code: ServerErrorCode.serverError.rawValue,
                             title: "L10n.foundationGeneralUnableToProceedTitle",
                             message: "L10n.foundationGeneralUnableToProceedMessage")
    }

    public static func notConnectedToInternet() -> ServerError {
        return ServerError(code: ServerErrorCode.notConnectedToInternet.rawValue,
                             title: "L10n.foundationGeneralNoInternetConnectionTitle",
                             message: "L10n.foundationGeneralNoInternetConnectionMessage")
    }
}

