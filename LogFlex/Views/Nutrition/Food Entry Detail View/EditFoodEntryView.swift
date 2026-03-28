//
//  EditFoodEntryView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI

struct EditFoodEntryView: View {
    @Binding var entry: NutritionEntry
    @Binding var foodName: String
    @Binding var calories: String
    @Binding var protein: String
    @Binding var carbs: String
    @Binding var fat: String
    @Binding var selectedMealType: NutritionEntry.MealType

    var onSave: () -> Void

    @Environment(\.presentationMode) var presentationMode

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
            }
            .navigationTitle("Edit Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
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
}

