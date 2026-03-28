//
//  NutritionEntry.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import Foundation

struct NutritionEntry: Identifiable, Codable {
    var id: UUID
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var date: Date
    var mealType: MealType

    enum MealType: String, Codable, CaseIterable, Identifiable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"

        var id: String { self.rawValue }
    }

    init(id: UUID = UUID(), name: String, calories: Int, protein: Double, carbs: Double, fat: Double, date: Date = Date(), mealType: MealType = .snack) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.mealType = mealType
    }
}
