//
//  SelectedDayNutritionView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI

struct SelectedDayNutritionView: View {
    let nutritionManager: NutritionManager
    let date: Date
    let dayData: DailyNutritionData

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(date, format: .dateTime.month().day().year())
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("Total: \(dayData.calories) calories")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            // Macronutrient summary
            HStack(spacing: 16) {
                MacroSummaryItem(title: "Protein", value: "\(Int(dayData.protein))g", color: .blue)
                MacroSummaryItem(title: "Carbs", value: "\(Int(dayData.carbs))g", color: .green)
                MacroSummaryItem(title: "Fat", value: "\(Int(dayData.fat))g", color: .yellow)
            }

            // Divider
            Rectangle()
                .fill(Color(.systemGray4))
                .frame(height: 1)

            // Meals for the day
            VStack(alignment: .leading, spacing: 12) {
                Text("Meals")
                    .font(.headline)

                ForEach(mealsByType, id: \.0) { mealType, entries in
                    if !entries.isEmpty {
                        MealTypeGroup(mealType: mealType, entries: entries)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    private var mealsByType: [(NutritionEntry.MealType, [NutritionEntry])] {
        let calendar = Calendar.current
        let dayEntries = nutritionManager.entries.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        return NutritionEntry.MealType.allCases.map { mealType in
            (mealType, dayEntries.filter { $0.mealType == mealType })
        }
    }
}

