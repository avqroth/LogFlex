//
//  NutritionGoal.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct NutritionGoalEditorView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @Environment(\.presentationMode) var presentationMode

    @State private var calorieGoal: Double
    @State private var proteinPercentage: Double
    @State private var carbsPercentage: Double
    @State private var fatPercentage: Double

    // Presets for calorie goals
    let caloriePresets = [1500, 1800, 2000, 2200, 2500]

    // Presets for macro splits (protein/carbs/fat)
    let macroPresets = [
        (0.30, 0.40, 0.30), // Balanced
        (0.40, 0.40, 0.20), // High protein
        (0.25, 0.55, 0.20), // High carb
        (0.30, 0.20, 0.50)  // Keto-friendly
    ]

    init(nutritionManager: NutritionManager) {
        self.nutritionManager = nutritionManager

        // Initialize state variables
        _calorieGoal = State(initialValue: Double(nutritionManager.dailyCalorieGoal))
        _proteinPercentage = State(initialValue: nutritionManager.proteinGoalPercentage * 100)
        _carbsPercentage = State(initialValue: nutritionManager.carbsGoalPercentage * 100)
        _fatPercentage = State(initialValue: nutritionManager.fatGoalPercentage * 100)
    }

    var totalPercentage: Double {
        proteinPercentage + carbsPercentage + fatPercentage
    }

    var macroBalanceDescription: String {
        if abs(totalPercentage - 100) < 0.1 {
            return "Balanced (100%)"
        } else if totalPercentage > 100 {
            return "Over 100% by \(String(format: "%.1f", totalPercentage - 100))%"
        } else {
            return "Under 100% by \(String(format: "%.1f", 100 - totalPercentage))%"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                // Calorie goal section
                Section(header: Text("Daily Calorie Goal")) {
                    Slider(value: $calorieGoal, in: 1200...3500, step: 50)

                    HStack {
                        Text("\(Int(calorieGoal)) calories")
                            .font(.headline)

                        Spacer()

                        // Quick preset buttons
                        HStack(spacing: 8) {
                            ForEach(caloriePresets, id: \.self) { preset in
                                Button(action: {
                                    calorieGoal = Double(preset)
                                }) {
                                    Text("\(preset)")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Int(calorieGoal) == preset ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(Int(calorieGoal) == preset ? .white : .primary)
                                }
                            }
                        }
                    }
                }

                // Macro distribution section
                Section(header: Text("Macronutrient Distribution"), footer: Text(macroBalanceDescription)) {
                    // Macro presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            MacroPresetButton(title: "Balanced", isSelected: isCurrentMacroSplit(macroPresets[0])) {
                                selectMacroPreset(macroPresets[0])
                            }

                            MacroPresetButton(title: "High Protein", isSelected: isCurrentMacroSplit(macroPresets[1])) {
                                selectMacroPreset(macroPresets[1])
                            }

                            MacroPresetButton(title: "High Carb", isSelected: isCurrentMacroSplit(macroPresets[2])) {
                                selectMacroPreset(macroPresets[2])
                            }

                            MacroPresetButton(title: "Keto", isSelected: isCurrentMacroSplit(macroPresets[3])) {
                                selectMacroPreset(macroPresets[3])
                            }
                        }
                    }
                    .padding(.vertical, 8)

                    // Protein slider
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Protein")
                            Spacer()
                            Text("\(Int(proteinPercentage))%")
                        }
                        Slider(value: $proteinPercentage, in: 10...60, step: 5)
                    }

                    // Carbs slider
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Carbohydrates")
                            Spacer()
                            Text("\(Int(carbsPercentage))%")
                        }
                        Slider(value: $carbsPercentage, in: 10...70, step: 5)
                    }

                    // Fat slider
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Fat")
                            Spacer()
                            Text("\(Int(fatPercentage))%")
                        }
                        Slider(value: $fatPercentage, in: 10...70, step: 5)
                    }
                }

                // Macro calculations section
                Section(header: Text("Daily Targets")) {
                    MacroTargetRow(
                        title: "Protein",
                        grams: (calorieGoal * (proteinPercentage / 100)) / 4, // 4 calories per gram
                        percentage: proteinPercentage,
                        color: .blue
                    )

                    MacroTargetRow(
                        title: "Carbs",
                        grams: (calorieGoal * (carbsPercentage / 100)) / 4, // 4 calories per gram
                        percentage: carbsPercentage,
                        color: .green
                    )

                    MacroTargetRow(
                        title: "Fat",
                        grams: (calorieGoal * (fatPercentage / 100)) / 9, // 9 calories per gram
                        percentage: fatPercentage,
                        color: .yellow
                    )
                }
            }
            .navigationTitle("Nutrition Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Save changes
                        nutritionManager.updateCalorieGoal(Int(calorieGoal))
                        nutritionManager.updateMacroGoals(
                            protein: proteinPercentage / 100,
                            carbs: carbsPercentage / 100,
                            fat: fatPercentage / 100
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    // Helper methods for macro presets
    private func selectMacroPreset(_ preset: (Double, Double, Double)) {
        proteinPercentage = preset.0 * 100
        carbsPercentage = preset.1 * 100
        fatPercentage = preset.2 * 100
    }

    private func isCurrentMacroSplit(_ preset: (Double, Double, Double)) -> Bool {
        let tolerance = 1.0
        return abs(proteinPercentage - preset.0 * 100) < tolerance &&
        abs(carbsPercentage - preset.1 * 100) < tolerance &&
        abs(fatPercentage - preset.2 * 100) < tolerance
    }
}

