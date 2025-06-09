//
//  NutritionManager.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import Foundation
import SwiftUI

class NutritionManager: ObservableObject {
    @Published var entries: [NutritionEntry] = []
    @Published var dailyCalorieGoal: Int = 2000
    @Published var proteinGoalPercentage: Double = 0.30
    @Published var carbsGoalPercentage: Double = 0.45
    @Published var fatGoalPercentage: Double = 0.25

    private let entriesKey = "nutritionEntries"
    private let calorieGoalKey = "nutritionCalorieGoal"
    private let macroGoalsKey = "nutritionMacroGoals"

    init() {
        loadData()
    }

    func loadData() {
        // Load entries
        if let data = UserDefaults.standard.data(forKey: entriesKey) {
            if let decoded = try? JSONDecoder().decode([NutritionEntry].self, from: data) {
                entries = decoded
            }
        }

        // Load calorie goal
        dailyCalorieGoal = UserDefaults.standard.integer(forKey: calorieGoalKey)
        if dailyCalorieGoal == 0 {
            dailyCalorieGoal = 2000 // Default value
        }

        // Load macro goals
        if let data = UserDefaults.standard.data(forKey: macroGoalsKey) {
            if let decoded = try? JSONDecoder().decode([Double].self, from: data) {
                if decoded.count == 3 {
                    proteinGoalPercentage = decoded[0]
                    carbsGoalPercentage = decoded[1]
                    fatGoalPercentage = decoded[2]
                }
            }
        }
    }

    func saveData() {
        // Save entries
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }

        // Save calorie goal
        UserDefaults.standard.set(dailyCalorieGoal, forKey: calorieGoalKey)

        // Save macro goals
        let macroGoals = [proteinGoalPercentage, carbsGoalPercentage, fatGoalPercentage]
        if let encoded = try? JSONEncoder().encode(macroGoals) {
            UserDefaults.standard.set(encoded, forKey: macroGoalsKey)
        }
    }

    func addEntry(_ entry: NutritionEntry) {
        entries.append(entry)
        saveData()
    }

    func updateEntry(_ entry: NutritionEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            saveData()
        }
    }

    func deleteEntry(at indexSet: IndexSet) {
        entries.remove(atOffsets: indexSet)
        saveData()
    }

    func updateCalorieGoal(_ goal: Int) {
        dailyCalorieGoal = goal
        saveData()
    }

    func updateMacroGoals(protein: Double, carbs: Double, fat: Double) {
        // Ensure percentages add up to 100%
        let total = protein + carbs + fat
        proteinGoalPercentage = protein / total
        carbsGoalPercentage = carbs / total
        fatGoalPercentage = fat / total
        saveData()
    }

    // MARK: - Calculations for Today's Data

    var todayEntries: [NutritionEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }

    var todayCalories: Int {
        todayEntries.reduce(0) { $0 + $1.calories }
    }

    var todayProtein: Double {
        todayEntries.reduce(0) { $0 + $1.protein }
    }

    var todayCarbs: Double {
        todayEntries.reduce(0) { $0 + $1.carbs }
    }

    var todayFat: Double {
        todayEntries.reduce(0) { $0 + $1.fat }
    }

    var calorieProgress: Double {
        guard dailyCalorieGoal > 0 else { return 0 }
        return min(Double(todayCalories) / Double(dailyCalorieGoal), 1.0)
    }

    var proteinGoalGrams: Double {
        (Double(dailyCalorieGoal) * proteinGoalPercentage) / 4.0 // 4 calories per gram of protein
    }

    var carbsGoalGrams: Double {
        (Double(dailyCalorieGoal) * carbsGoalPercentage) / 4.0 // 4 calories per gram of carbs
    }

    var fatGoalGrams: Double {
        (Double(dailyCalorieGoal) * fatGoalPercentage) / 9.0 // 9 calories per gram of fat
    }

    var proteinProgress: Double {
        guard proteinGoalGrams > 0 else { return 0 }
        return min(todayProtein / proteinGoalGrams, 1.0)
    }

    var carbsProgress: Double {
        guard carbsGoalGrams > 0 else { return 0 }
        return min(todayCarbs / carbsGoalGrams, 1.0)
    }

    var fatProgress: Double {
        guard fatGoalGrams > 0 else { return 0 }
        return min(todayFat / fatGoalGrams, 1.0)
    }

    func entriesForMeal(_ mealType: NutritionEntry.MealType) -> [NutritionEntry] {
        todayEntries.filter { $0.mealType == mealType }
    }

    func caloriesForMeal(_ mealType: NutritionEntry.MealType) -> Int {
        entriesForMeal(mealType).reduce(0) { $0 + $1.calories }
    }
}

