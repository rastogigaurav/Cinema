//
//  Application.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation
import UIKit

struct Application {
    public enum AppEnvironment: String {
        case local = "LOCAL"
        case prod = "PROD"
    }

    public struct Constants {
        static let bundleShortVersionString = "CFBundleShortVersionString"
        static let bundleVersionString = "CFBundleVersion"
        static let config = "Config"
        static let appEnvironment = "AppEnvironment"
    }

    private static let infoDictionary: [String: Any] = {
        guard let dictionary = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dictionary
    }()

    public static let appVersion: String = {
        guard let version = Application.infoDictionary[Constants.bundleShortVersionString] as? String else {
            return "1.0.0"
        }
        return version
    }()

    public static let buildNumber: String = {
        guard let build = Application.infoDictionary[Constants.bundleVersionString] as? String else {
            return "1"
        }
        return build
    }()

    private static let configDictionary: [String: Any] = {
        guard let config = Application.infoDictionary[Constants.config] as? [String: Any] else {
            return [:]
        }
        return config
    }()

    public static let appEnvironment: String = {
        guard let environment = Application.configDictionary[Constants.appEnvironment] as? String else {
            return ""
        }
        return environment
    }()

    public static let debug: Bool = {
        guard let environment = Application.configDictionary[Constants.appEnvironment] as? String,
              let appEnvironment = AppEnvironment(rawValue: environment) else {
            return false
        }
        switch appEnvironment {
        case .local:
            return true
        case .prod:
            fallthrough
        @unknown default:
            return false
        }
    }()
}
