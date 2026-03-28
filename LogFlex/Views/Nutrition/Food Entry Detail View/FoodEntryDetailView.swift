//
//  FoodEntryDetailView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI
struct FoodEntryDetailView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @Environment(\.presentationMode) var presentationMode

    @State private var entry: NutritionEntry
    @State private var foodName: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var selectedMealType: NutritionEntry.MealType
    @State private var isEditing: Bool = false

    init(nutritionManager: NutritionManager, entry: NutritionEntry) {
        self.nutritionManager = nutritionManager
        self._entry = State(initialValue: entry)
        self._foodName = State(initialValue: entry.name)
        self._calories = State(initialValue: "\(entry.calories)")
        self._protein = State(initialValue: String(format: "%.1f", entry.protein))
        self._carbs = State(initialValue: String(format: "%.1f", entry.carbs))
        self._fat = State(initialValue: String(format: "%.1f", entry.fat))
        self._selectedMealType = State(initialValue: entry.mealType)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header card
                VStack(spacing: 12) {
                    Text(entry.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("\(entry.calories) calories")
                        .font(.title3)

                    Text(entry.mealType.rawValue)
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(mealTypeColor(entry.mealType).opacity(0.2))
                        )
                        .foregroundColor(mealTypeColor(entry.mealType))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                // Macros card
                VStack(spacing: 16) {
                    Text("Nutrition Facts")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    MacroDetailRow(title: "Calories", value: "\(entry.calories)", unit: "kcal")
                    MacroDetailRow(title: "Protein", value: String(format: "%.1f", entry.protein), unit: "g")
                    MacroDetailRow(title: "Carbohydrates", value: String(format: "%.1f", entry.carbs), unit: "g")
                    MacroDetailRow(title: "Fat", value: String(format: "%.1f", entry.fat), unit: "g")
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)

                // Macro pie chart visualization
                VStack(spacing: 16) {
                    Text("Macro Distribution")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    MacroPieChart(protein: entry.protein, carbs: entry.carbs, fat: entry.fat)
                        .frame(height: 200)

                    HStack(spacing: 20) {
                        MacroLegendItem(color: .blue, title: "Protein", percentage: calculatePercentage(entry.protein, 4))
                        MacroLegendItem(color: .green, title: "Carbs", percentage: calculatePercentage(entry.carbs, 4))
                        MacroLegendItem(color: .yellow, title: "Fat", percentage: calculatePercentage(entry.fat, 9))
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Food Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditFoodEntryView(
                entry: $entry,
                foodName: $foodName,
                calories: $calories,
                protein: $protein,
                carbs: $carbs,
                fat: $fat,
                selectedMealType: $selectedMealType,
                onSave: saveChanges
            )
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

    private func calculatePercentage(_ amount: Double, _ caloriesPerGram: Double) -> Double {
        let totalCalories = Double(entry.calories)
        guard totalCalories > 0 else { return 0 }

        let macroCalories = amount * caloriesPerGram
        return (macroCalories / totalCalories) * 100
    }

    private func saveChanges() {
        guard let caloriesInt = Int(calories),
              let proteinDouble = Double(protein),
              let carbsDouble = Double(carbs),
              let fatDouble = Double(fat) else {
            return
        }

        entry.name = foodName
        entry.calories = caloriesInt
        entry.protein = proteinDouble
        entry.carbs = carbsDouble
        entry.fat = fatDouble
        entry.mealType = selectedMealType

        nutritionManager.updateEntry(entry)
        isEditing = false
    }
}

