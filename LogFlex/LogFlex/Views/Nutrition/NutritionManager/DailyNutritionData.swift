//
//  DailyNutritionData.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI

struct DailyNutritionData: Identifiable {
    var id = UUID()
    var date: Date
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
}

