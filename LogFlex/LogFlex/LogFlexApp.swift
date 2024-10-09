//
//  LogFlexApp.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI
import SwiftData

@main
struct LogFlexApp: App {
    @StateObject private var healthKit = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKit)
        }
    }
}
