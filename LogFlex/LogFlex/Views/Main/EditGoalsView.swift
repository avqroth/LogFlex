//
//  EditGoalsView.swift
//  LogFlex
//
//  Created by Avery Roth on 3/11/25.
//

import SwiftUI

struct EditGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var goals: UserGoals

    // Temporary state to hold changes
    @State private var tempStepGoal: Int
    @State private var tempCalorieGoal: Int

    init(goals: UserGoals) {
        self.goals = goals
        // Initialize with current values
        _tempStepGoal = State(initialValue: goals.stepGoal)
        _tempCalorieGoal = State(initialValue: goals.calorieGoal)
    }

    var body: some View {
        Form {
            Section("Step Goal") {
                VStack(alignment: .leading) {
                    Text("\(tempStepGoal) steps")
                        .font(.title3)
                        .bold()

                    Slider(
                        value: .init(
                            get: { Double(tempStepGoal) },
                            set: { tempStepGoal = Int($0) }
                        ),
                        in: 1000...50000,
                        step: 1000
                    )
                }
            }

            Section("Calorie Goal") {
                VStack(alignment: .leading) {
                    Text("\(tempCalorieGoal) calories")
                        .font(.title3)
                        .bold()

                    Slider(
                        value: .init(
                            get: { Double(tempCalorieGoal) },
                            set: { tempCalorieGoal = Int($0) }
                        ),
                        in: 100...2000,
                        step: 50
                    )
                }
            }

            Section("Preset Step Goals") {
                ForEach([5000, 7500, 10000, 12500, 15000], id: \.self) { preset in
                    Button(action: { tempStepGoal = preset }) {
                        HStack {
                            Text("\(preset) steps")
                            Spacer()
                            if tempStepGoal == preset {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveChanges()
                    dismiss()
                }
            }
        }
    }

    private func saveChanges() {
        goals.stepGoal = tempStepGoal
        goals.calorieGoal = tempCalorieGoal

        try? modelContext.save()
    }
}

