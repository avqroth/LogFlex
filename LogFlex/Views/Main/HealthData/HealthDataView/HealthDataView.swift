//
//  HealthProgressCircle.swift
//  LogFlex
//
//  Created by Avery Roth on 10/3/24.
//

import SwiftUI

struct HealthDataView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var showingStepGoalEditor = false
    @State private var showingCalorieGoalEditor = false
    @State private var tempStepGoal: Double = 10000
    @State private var tempCalorieGoal: Double = 500
    @State private var showingGoalTypeSelection = false

    var body: some View {
        VStack(spacing: 25) {
            HStack {
                Text("Today's Activity")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                Button(action: {
                    showingGoalTypeSelection = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.main)
                }
                .confirmationDialog("Select Goal to Edit", isPresented: $showingGoalTypeSelection) {
                    Button("Edit Step Goal") {
                        tempStepGoal = Double(healthKitManager.currentStepGoal)
                        showingStepGoalEditor = true
                    }

                    Button("Edit Calorie Goal") {
                        tempCalorieGoal = healthKitManager.goalCalories
                        showingCalorieGoalEditor = true
                    }

                    Button("Cancel", role: .cancel) { }
                }
            }
            .padding(.horizontal)
            .padding(.trailing)
            .padding(.bottom)

            HStack(spacing: 20) {
                VStack {
                    ActivityProgressCircle(
                        title: "Steps",
                        value: formatNumber(healthKitManager.stepCount),
                        progress: healthKitManager.progress,
                        icon: "figure.walk",
                        color: .stand
                    )

                    Text("Goal: \(formatNumber(healthKitManager.currentStepGoal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    ActivityProgressCircle(
                        title: "Calories",
                        value: formatNumber(Int(healthKitManager.caloriesBurned)),
                        progress: healthKitManager.caloriesProgress,
                        icon: "flame.fill",
                        color: .accent
                    )

                    Text("Goal: \(formatNumber(Int(healthKitManager.goalCalories)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                VStack {
                    ActivityProgressCircle(
                        title: "Stand",
                        value: "\(healthKitManager.standHours)",
                        progress: min(Double(healthKitManager.standHours) / 12.0, 1.0),
                        icon: "figure.stand",
                        color: .main
                    )

                    Text("Goal: 12 hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .sheet(isPresented: $showingStepGoalEditor) {
            GoalSliderView(
                title: "Edit Step Goal",
                value: $tempStepGoal,
                range: 1000...25000,
                step: 500,
                presets: [5000, 7500, 10000, 12500, 15000],
                formatter: { formatNumber(Int($0)) },
                onSave: {
                    healthKitManager.updateStepGoal(Int(tempStepGoal))
                    showingStepGoalEditor = false
                },
                onCancel: {
                    showingStepGoalEditor = false
                }
            )
        }
        .sheet(isPresented: $showingCalorieGoalEditor) {
            GoalSliderView(
                title: "Edit Calorie Goal",
                value: $tempCalorieGoal,
                range: 100...2000,
                step: 50,
                presets: [300, 500, 700, 1000, 1500],
                formatter: { formatNumber(Int($0)) },
                onSave: {
                    healthKitManager.updateCalorieGoal(tempCalorieGoal)
                    showingCalorieGoalEditor = false
                },
                onCancel: {
                    showingCalorieGoalEditor = false
                }
            )
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

struct ActivityProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ActivityProgressCircle(
            title: "Steps",
            value: "8,546",
            progress: 0.75,
            icon: "figure.walk",
            color: .blue
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

struct HealthDataView_Previews: PreviewProvider {
    static var previews: some View {
        HealthDataView(healthKitManager: HealthKitManager())
            .previewLayout(.sizeThatFits)
    }
}

struct GoalSliderView_Previews: PreviewProvider {
    static var previews: some View {
        GoalSliderView(
            title: "Edit Step Goal",
            value: .constant(10000),
            range: 1000...25000,
            step: 500,
            presets: [5000, 7500, 10000, 12500, 15000],
            formatter: { "\(Int($0))" },
            onSave: { },
            onCancel: { }
        )
    }
}
