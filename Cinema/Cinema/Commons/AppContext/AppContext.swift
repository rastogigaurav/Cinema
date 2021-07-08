//
//  AppContext.swift
//  Cinema
//
//  Created by g.b.rastogi on 08/07/2021.
//

import Foundation

// MARK: - Config Keys
/// Usage: Define this to help you maintain
/// `key` in `info.plist`
enum ConfigKeys: String {
    case appEnv = "AppEnvironment"
    case baseUrl = "BaseURL"
    case appName = "CFBundleName"
}

class AppContext {
    
    init() { }
    
    static var instance: AppContext {
        return AppContext()
    }
    /// This method allow to read `Bundle`
    /// Read configuration for `.xconfig`
    /// whenever variable defines in `.xconfig`
    /// it can be read using this function
    /// and don't forget to defined variable into `.plist`
    func infoForKey(_ key: String, defaultValue: String = "") -> String {
        let dictionary = Bundle.main.infoDictionary?["Config"] as? NSDictionary
        if let value = (dictionary?[key] as? String)?.replacingOccurrences(of: "\\", with: "") {
            return value
        } else {
            return defaultValue
        }
    }
}

