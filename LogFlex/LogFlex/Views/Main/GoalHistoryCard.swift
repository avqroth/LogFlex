//
//  GoalHistoryCard.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI
import SwiftData

@Model
class UserGoals {
    var id: UUID
    var stepGoal: Int
    var calorieGoal: Int

    init(id: UUID = UUID(), stepGoal: Int = 10000, calorieGoal: Int = 500) {
        self.id = id
        self.stepGoal = stepGoal
        self.calorieGoal = calorieGoal
    }
}

struct GoalHistoryCard: View {
    let healthKitManager: HealthKitManager
    @State private var weeklySteps: [Double] = Array(repeating: 0, count: 7)
    @State private var weeklyCalories: [Double] = Array(repeating: 0, count: 7)
    @State private var showingGoalEditor = false
    @Query private var userGoals: [UserGoals]
    @Environment(\.modelContext) private var modelContext
    @State private var refreshToggle = false  // Add this to force refresh

    private var currentGoals: UserGoals {
        if let existingGoals = userGoals.first {
            return existingGoals
        } else {
            let newGoals = UserGoals()
            modelContext.insert(newGoals)
            try? modelContext.save()
            return newGoals
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Progress")
                        .font(.title3)
                        .fontWeight(.semibold)

                    HStack(spacing: 24) {
                        ProgressMetricView(
                            icon: "flame.fill",
                            value: Int(healthKitManager.caloriesBurned),
                            goal: currentGoals.calorieGoal,
                            color: .orange
                        )

                        ProgressMetricView(
                            icon: "figure.walk",
                            value: healthKitManager.stepCount,
                            goal: currentGoals.stepGoal,
                            color: .green
                        )
                    }
                }

                Spacer()

                Button(action: { showingGoalEditor = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .id(refreshToggle)  // Force refresh when goals change

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                Text("This Week's Steps")
                    .font(.title3)
                    .fontWeight(.semibold)

                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(0..<7, id: \.self) { index in
                        DayProgressBar(
                            progress: weeklySteps[index] / Double(currentGoals.stepGoal),
                            value: Int(weeklySteps[index]),
                            dayIndex: index
                        )
                    }
                }
                .frame(height: 100)
                .padding(.horizontal, 8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .gray.opacity(0.2), radius: 10)
        .sheet(isPresented: $showingGoalEditor) {
            NavigationStack {
                EditGoalsView(goals: currentGoals)
                    .onDisappear {
                        refreshToggle.toggle()  // Force refresh when sheet dismisses
                    }
            }
        }
        .onAppear {
            fetchWeeklyData()
        }
    }

    private func fetchWeeklyData() {
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                healthKitManager.fetchSteps(for: date) { steps in
                    weeklySteps[6-i] = Double(steps)
                }
                healthKitManager.fetchCalories(for: date) { calories in
                    weeklyCalories[6-i] = calories
                }
            }
        }
    }
}

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
        // Update the model
        goals.stepGoal = tempStepGoal
        goals.calorieGoal = tempCalorieGoal

        // Save to SwiftData
        try? modelContext.save()
    }
}


#Preview {
    GoalHistoryCard(healthKitManager: HealthKitManager())
}
