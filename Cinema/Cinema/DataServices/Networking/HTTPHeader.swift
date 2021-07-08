//
//  HTTPHeader.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation
import UIKit

public enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case language = "Accept-Language"
    case requestId = "X-Request-ID"
    case platform = "X-Platform"
    case clientVersion = "X-Client-Version"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
    case deviceID = "X-Device-ID"
    case channelID = "X-Channel-Id"
    case deviceModel = "X-Device-Model"
    case correlationId = "X-Correlation-ID"

    public static func commonHeader() -> [String: String] {
        let commonHeader = [
            HTTPHeaderField.contentType.rawValue: HttpContentType.json.rawValue,
            HTTPHeaderField.channelID.rawValue: "MB",
            HTTPHeaderField.correlationId.rawValue: UUID().uuidString,
            HTTPHeaderField.platform.rawValue: "ios/" + String(UIDevice.current.systemVersion)
        ]
        return commonHeader
    }
}

public enum HttpContentType: String {
    case json = "application/json"
}
