//
//  StepGoalEditSheet.swift
//  LogFlex
//
//  Created by Avery Roth on 3/11/25.
//

import SwiftUI

struct StepGoalEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var stepGoal: Double
    @State private var calorieGoal: Double
    @State private var selectedGoalType: GoalType = .steps
    let mainColor = Color.main

    enum GoalType: String, CaseIterable {
        case steps = "Steps"
        case calories = "Calories"
    }

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        _stepGoal = State(initialValue: Double(healthKitManager.currentStepGoal))
        _calorieGoal = State(initialValue: healthKitManager.goalCalories)
    }

    var body: some View {
        NavigationView {
            Form {
                Picker("Goal Type", selection: $selectedGoalType) {
                    ForEach(GoalType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                if selectedGoalType == .steps {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(Int(stepGoal))")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("steps")
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(.gray)
                            }

                            Slider(
                                value: $stepGoal,
                                in: 1000...30000,
                                step: 500
                            )
                            .tint(mainColor)
                        }
                    }

                    Section {
                        ForEach([5000, 7500, 10000, 12500, 15000], id: \.self) { preset in
                            Button(action: { stepGoal = Double(preset) }) {
                                HStack {
                                    Text("\(preset) steps")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if Int(stepGoal) == preset {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(mainColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Suggested Goals")
                    }
                } else if selectedGoalType == .calories {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("\(Int(calorieGoal))")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                Text("calories")
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(.gray)
                            }

                            Slider(
                                value: $calorieGoal,
                                in: 100...2000,
                                step: 50
                            )
                            .tint(mainColor)
                        }
                    }

                    Section {
                        ForEach([300, 500, 750, 1000, 1500], id: \.self) { preset in
                            Button(action: { calorieGoal = Double(preset) }) {
                                HStack {
                                    Text("\(preset) calories")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if Int(calorieGoal) == preset {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(mainColor)
                                    }
                                }
                            }
                        }
                    } header: {
                        Text("Suggested Goals")
                    }
                }
            }
            .navigationTitle("Activity Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if selectedGoalType == .steps {
                            healthKitManager.updateStepGoal(Int(stepGoal))
                        } else if selectedGoalType == .calories {
                            healthKitManager.updateCalorieGoal(calorieGoal)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}
