//
//  MealTypeGroup.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI

struct MealTypeGroup: View {
    let mealType: NutritionEntry.MealType
    let entries: [NutritionEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mealType.rawValue)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(mealTypeColor(mealType))

            ForEach(entries) { entry in
                HStack {
                    Text(entry.name)
                        .font(.caption)

                    Spacer()

                    Text("\(entry.calories) cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
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

