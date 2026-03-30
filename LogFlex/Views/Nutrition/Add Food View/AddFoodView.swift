//
//  AddFoodView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//
import SwiftUI

struct AddFoodView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @Environment(\.presentationMode) var presentationMode

    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var selectedMealType: NutritionEntry.MealType = .lunch

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Details")) {
                    TextField("Food name", text: $foodName)

                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)

                    Picker("Meal", selection: $selectedMealType) {
                        ForEach(NutritionEntry.MealType.allCases, id: \.self) { mealType in
                            Text(mealType.rawValue).tag(mealType)
                        }
                    }
                }

                Section(header: Text("Macronutrients (grams)")) {
                    TextField("Protein (g)", text: $protein)
                        .keyboardType(.decimalPad)

                    TextField("Carbs (g)", text: $carbs)
                        .keyboardType(.decimalPad)

                    TextField("Fat (g)", text: $fat)
                        .keyboardType(.decimalPad)
                }

                // Quick add presets
                Section(header: Text("Quick Add")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            QuickAddButton(title: "Coffee", calories: 5, protein: 0, carbs: 0, fat: 0) {
                                selectPreset(name: "Coffee", calories: 5, protein: 0, carbs: 0, fat: 0)
                            }

                            QuickAddButton(title: "Protein Shake", calories: 150, protein: 25, carbs: 5, fat: 2) {
                                selectPreset(name: "Protein Shake", calories: 150, protein: 25, carbs: 5, fat: 2)
                            }

                            QuickAddButton(title: "Apple", calories: 95, protein: 0, carbs: 25, fat: 0) {
                                selectPreset(name: "Apple", calories: 95, protein: 0, carbs: 25, fat: 0)
                            }

                            QuickAddButton(title: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6) {
                                selectPreset(name: "Chicken Breast", calories: 165, protein: 31, carbs: 0, fat: 3.6)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveFood()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !foodName.isEmpty &&
        !calories.isEmpty &&
        !protein.isEmpty &&
        !carbs.isEmpty &&
        !fat.isEmpty &&
        Int(calories) != nil &&
        Double(protein) != nil &&
        Double(carbs) != nil &&
        Double(fat) != nil
    }

    private func selectPreset(name: String, calories: Int, protein: Double, carbs: Double, fat: Double) {
        foodName = name
        self.calories = "\(calories)"
        self.protein = String(format: "%.1f", protein)
        self.carbs = String(format: "%.1f", carbs)
        self.fat = String(format: "%.1f", fat)
    }

    private func saveFood() {
        guard let caloriesInt = Int(calories),
              let proteinDouble = Double(protein),
              let carbsDouble = Double(carbs),
              let fatDouble = Double(fat) else {
            return
        }

        let newEntry = NutritionEntry(
            name: foodName,
            calories: caloriesInt,
            protein: proteinDouble,
            carbs: carbsDouble,
            fat: fatDouble,
            date: Date(),
            mealType: selectedMealType
        )

        nutritionManager.addEntry(newEntry)
        presentationMode.wrappedValue.dismiss()
    }
}
