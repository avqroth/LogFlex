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
    let calorieColor = Color.accent
    let standColor = Color.stand

    var stepProgress: Double {
        Double(healthKitManager.stepCount) / Double(healthKitManager.currentStepGoal)
    }

    var calorieProgress: Double {
        healthKitManager.caloriesBurned / healthKitManager.goalCalories
    }

    var standProgress: Double {
        Double(healthKitManager.standHours) / 12.0
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 300)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(stepProgress, 1.0)))
                .stroke(mainColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 300)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: stepProgress)

            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 240)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(calorieProgress, 1.0)))
                .stroke(calorieColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 240)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: calorieProgress)

            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 180)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(standProgress, 1.0)))
                .stroke(standColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 180)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: standProgress)

            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk")
                        .foregroundColor(mainColor)

                    Text("\(healthKitManager.stepCount)")
                        .fontWeight(.semibold)
                        .foregroundColor(mainColor)
                }

                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(calorieColor)

                    Text("\(Int(healthKitManager.caloriesBurned)) cal")
                        .fontWeight(.semibold)
                        .foregroundColor(calorieColor)
                }

                HStack(spacing: 4) {
                    Image(systemName: "figure.stand")
                        .foregroundColor(standColor)

                    Text("\(healthKitManager.standHours)/12 hr")
                        .fontWeight(.semibold)
                        .foregroundColor(standColor)
                }

                Button(action: { showingStepGoalEdit = true }) {
                    Label("Edit Goals", systemImage: "pencil.circle.fill")
                        .font(.system(.footnote, design: .rounded))
                        .foregroundColor(.indigo)
                        .padding(.top, 4)
                }
            }
        }
        .frame(width: 300, height: 300)
        .padding()
        .onAppear {
            healthKitManager.fetchTodaySteps()
            healthKitManager.fetchTodayCalories()
            healthKitManager.fetchStandHours()
        }
        .sheet(isPresented: $showingStepGoalEdit) {
            StepGoalEditSheet(healthKitManager: healthKitManager)
        }
    }
}
