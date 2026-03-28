//
//  NutritionProgressCard.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct NutritionProgressCard: View {
    @ObservedObject var nutritionManager: NutritionManager
    @State private var showingGoalEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Calories row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.headline)

                    Text("\(nutritionManager.todayCalories) / \(nutritionManager.dailyCalorieGoal)")
                        .font(.subheadline)
                }

                Spacer()

                Button(action: {
                    showingGoalEditor = true
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
            }

            // Calorie progress bar
            ProgressBar(value: nutritionManager.calorieProgress, color: .orange)
                .frame(height: 10)

            // Macros
            HStack(spacing: 16) {
                // Protein
                MacroProgressItem(
                    title: "Protein",
                    value: "\(Int(nutritionManager.todayProtein))g",
                    progress: nutritionManager.proteinProgress,
                    color: .blue
                )

                // Carbs
                MacroProgressItem(
                    title: "Carbs",
                    value: "\(Int(nutritionManager.todayCarbs))g",
                    progress: nutritionManager.carbsProgress,
                    color: .green
                )

                // Fat
                MacroProgressItem(
                    title: "Fat",
                    value: "\(Int(nutritionManager.todayFat))g",
                    progress: nutritionManager.fatProgress,
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showingGoalEditor) {
            NutritionGoalEditorView(nutritionManager: nutritionManager)
        }
    }
}

