//
//  WaterLog.swift
//  LogFlex
//
//  Created by Avery Roth on 2/13/25.
//

import Foundation
import SwiftData

@Model
final class WaterLog: Identifiable {
    @Attribute(.unique) var id: UUID
    var amount: Double
    var date: Date

    init(amount: Double, date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.date = date
    }
}

@Observable
class WaterTrackingViewModel {
    var todayIntake: Double = 0
    let dailyGoal: Double = 64 // Default goal of 64oz

    var progressPercentage: Double {
        min((todayIntake / dailyGoal) * 100, 100)
    }

    func addWater(_ amount: Double) {
        todayIntake += amount
    }

    func removeWater(_ amount: Double) {
        todayIntake = max(0, todayIntake - amount)
    }
}

