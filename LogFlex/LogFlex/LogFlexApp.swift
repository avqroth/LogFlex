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
    @StateObject private var healthKitManager = HealthKitManager()
  

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthKitManager)
        }
        .modelContainer(for: [
            WorkoutLog.self,
            ExerciseLog.self,
            WaterLog.self
        ])
    }
}
