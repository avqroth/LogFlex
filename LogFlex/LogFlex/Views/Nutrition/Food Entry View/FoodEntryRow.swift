//
//  Untitled 3.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct FoodEntryRow: View {
    var entry: NutritionEntry

    var body: some View {
        HStack(spacing: 12) {
            // Food icon
            ZStack {
                Circle()
                    .fill(mealTypeColor(entry.mealType).opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: mealTypeIcon(entry.mealType))
                    .foregroundColor(mealTypeColor(entry.mealType))
            }

            // Food details
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.headline)

                HStack {
                    Text("\(entry.calories) cal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(formatMacros(protein: entry.protein, carbs: entry.carbs, fat: entry.fat))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Meal type tag
            Text(entry.mealType.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(mealTypeColor(entry.mealType).opacity(0.2))
                )
                .foregroundColor(mealTypeColor(entry.mealType))
        }
        .padding(.vertical, 4)
    }

    private func mealTypeIcon(_ mealType: NutritionEntry.MealType) -> String {
        switch mealType {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "applelogo"
        }
    }

    private func mealTypeColor(_ mealType: NutritionEntry.MealType) -> Color {
        switch mealType {
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .purple
        case .snack: return .green
        }
    }

    private func formatMacros(protein: Double, carbs: Double, fat: Double) -> String {
        return "P: \(Int(protein))g • C: \(Int(carbs))g • F: \(Int(fat))g"
    }
}

