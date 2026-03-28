//
//  Untitled 4.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct MacroSummaryBar: View {
    @ObservedObject var nutritionManager: NutritionManager

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 20) {
                VStack {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(nutritionManager.todayCalories)")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 30)

                VStack {
                    Text("Protein")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(nutritionManager.todayProtein))g")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 30)

                VStack {
                    Text("Carbs")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(nutritionManager.todayCarbs))g")
                        .font(.headline)
                }

                Divider()
                    .frame(height: 30)

                VStack {
                    Text("Fat")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(Int(nutritionManager.todayFat))g")
                        .font(.headline)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(Color(.systemBackground))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
        }
    }
}

