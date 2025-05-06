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

    var body: some View {
        VStack(spacing: 25) {
            // Title
            Text("Today's Activity")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom)

            // Progress circles
            HStack(spacing: 20) {
                // Steps progress with edit button
                VStack {
                    ActivityProgressCircle(
                        title: "Steps",
                        value: formatNumber(healthKitManager.stepCount),
                        progress: healthKitManager.progress,
                        icon: "figure.walk",
                        color: .stand
                    )
                    .onTapGesture {
                        tempStepGoal = Double(healthKitManager.currentStepGoal)
                        showingStepGoalEditor = true
                    }

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
                    .onTapGesture {
                        tempCalorieGoal = healthKitManager.goalCalories
                        showingCalorieGoalEditor = true
                    }

                    Text("Goal: \(formatNumber(Int(healthKitManager.goalCalories)))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Stand hours progress
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
        // Step goal editor sheet
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
        // Calorie goal editor sheet
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

// Goal Slider View with Presets
struct GoalSliderView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let presets: [Double]
    let formatter: (Double) -> String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Current Goal: \(formatter(value))")
                    .font(.headline)
                    .padding(.top)

                // Preset buttons
                VStack(alignment: .leading, spacing: 10) {
                    Text("Presets:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(presets, id: \.self) { preset in
                                Button(action: {
                                    value = preset
                                }) {
                                    Text(formatter(preset))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(value == preset ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(value == preset ? .white : .primary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Custom slider
                VStack(alignment: .leading, spacing: 10) {
                    Text("Custom:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack {
                        Slider(
                            value: $value,
                            in: range,
                            step: step
                        )

                        HStack {
                            Text(formatter(range.lowerBound))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(formatter(range.upperBound))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
            .padding()
        }
    }
}

struct ActivityProgressCircle: View {
    let title: String
    let value: String
    let progress: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            // Progress circle
            ZStack {
                // Background circle
                Circle()
                    .stroke(
                        color.opacity(0.2),
                        lineWidth: 10
                    )

                // Progress circle
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)

                // Center icon
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            .frame(width: 100, height: 100)

            // Value
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)

            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct HealthProgressCircle: View {
    @ObservedObject var healthKitManager: HealthKitManager

    var body: some View {
        HealthDataView(healthKitManager: healthKitManager)
    }
}

// Preview providers
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
