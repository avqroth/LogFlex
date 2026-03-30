//
//  SecretsManager.swift
//  LogFlex
//

import Foundation

enum SecretsManager {

    static var apiNinjaKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_NINJA_KEY") as? String,
              !key.isEmpty else {
            #if DEBUG
            print("❌ API_NINJA_KEY missing from Info.plist — check Build Settings")
            return ""  // ✅ returns empty string instead of crashing
            #else
            fatalError("🔑 API_NINJA_KEY is missing from Info.plist")  // still crashes in prod if misconfigured
            #endif
        }
        return key
    }
}
