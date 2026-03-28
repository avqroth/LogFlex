//
//  CompactFoodEntryRow.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct CompactFoodEntryRow: View {
    var entry: NutritionEntry

    var body: some View {
        HStack {
            // Meal icon with background
            ZStack {
                Circle()
                    .fill(mealTypeColor(entry.mealType).opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: mealTypeIcon(entry.mealType))
                    .font(.system(size: 16))
                    .foregroundColor(mealTypeColor(entry.mealType))
            }

            // Food info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(entry.calories) cal · P: \(Int(entry.protein))g · C: \(Int(entry.carbs))g · F: \(Int(entry.fat))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
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
}

