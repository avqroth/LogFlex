//
//  HealthProgressCircle.swift
//  LogFlex
//
//  Created by Avery Roth on 10/3/24.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}

struct HealthProgressCircle: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var showingStepGoalEdit = false
    let mainColor = Color.main
    let secondaryColor = Color.backup

    var stepProgress: Double {
        Double(healthKitManager.stepCount) / Double(healthKitManager.currentStepGoal)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 300)
                .padding()

            Circle()
                .trim(from: 0.0, to: CGFloat(min(healthKitManager.progress, 1.0)))
                .stroke(mainColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(width: 300)
                .rotationEffect(.degrees(-90))
                .shadow(color: mainColor.opacity(0.5), radius: 8, x: 0, y: 0)
                .shadow(color: mainColor.opacity(0.3), radius: 12, x: 0, y: 0)
                .animation(.linear, value: healthKitManager.progress)
                .padding()

            Circle()
                .trim(from: 0.0, to: CGFloat(min(stepProgress, 1.0)))
                .stroke(mainColor, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(width: 300)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: stepProgress)
                .padding()

            VStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(.accent)
                    .font(.system(size: 30))

                Text("\(healthKitManager.stepCount)/\(healthKitManager.currentStepGoal)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                Text("Today")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.accent)

                Button(action: { showingStepGoalEdit = true }) {
                    Label("Edit Goal", systemImage: "pencil.circle.fill")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.accent)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear {
            healthKitManager.fetchTodaySteps()
        }
        .sheet(isPresented: $showingStepGoalEdit) {
            StepGoalEditSheet(healthKitManager: healthKitManager)
        }
    }
}

struct StepGoalEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var stepGoal: Double
    let mainColor = Color.main

    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        _stepGoal = State(initialValue: Double(healthKitManager.currentStepGoal))
    }

    var body: some View {
        NavigationView {
            Form {
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
            }
            .navigationTitle("Daily Step Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        healthKitManager.updateStepGoal(Int(stepGoal))
                        dismiss()
                    }
                }
            }
        }
    }
}
