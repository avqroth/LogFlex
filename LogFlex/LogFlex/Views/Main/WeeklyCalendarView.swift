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

struct WeeklyCalendarView: View {
    let healthKitManager: HealthKitManager
    @State private var weeklySteps: [Double] = Array(repeating: 0, count: 7)
    @State private var weeklyCalories: [Double] = Array(repeating: 0, count: 7)
    @State private var showingGoalEditor = false
    @Query private var userGoals: [UserGoals]
    @Environment(\.modelContext) private var modelContext
    @State private var currentStepGoal: Int = 10000
    @State private var currentCalorieGoal: Int = 500
    @State private var selectedTab = 0

    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

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

    private var averageSteps: Int {
        let total = weeklySteps.reduce(0, +)
        return Int(total / Double(weeklySteps.count))
    }

    private var averageCalories: Int {
        let total = weeklyCalories.reduce(0, +)
        return Int(total / Double(weeklyCalories.count))
    }

    private var stepGoalCompletion: Double {
        Double(averageSteps) / Double(currentStepGoal)
    }

    private var calorieGoalCompletion: Double {
        Double(averageCalories) / Double(currentCalorieGoal)
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                SummaryCard(
                    title: "Steps",
                    icon: "figure.walk",
                    color: .stand,
                    average: averageSteps,
                    goal: currentStepGoal,
                    completion: stepGoalCompletion
                )

                SummaryCard(
                    title: "Calories",
                    icon: "flame.fill",
                    color: .accent,
                    average: averageCalories,
                    goal: currentCalorieGoal,
                    completion: calorieGoalCompletion
                )
            }
            .frame(height: 120)

            Picker("Data Type", selection: $selectedTab) {
                Text("Steps").tag(0)
                Text("Calories").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 12) {
                Text(selectedTab == 0 ? "This Week's Steps" : "This Week's Calories")
                    .font(.headline)
                    .padding(.bottom, 4)

                fixedWeeklyChart()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .onAppear {
            fetchCurrentWeekData()
        }
    }

    private func fixedWeeklyChart() -> some View {
        let currentColor = selectedTab == 0 ? Color.stand : Color.accent
        let values = selectedTab == 0 ? weeklySteps : weeklyCalories
        let goal = selectedTab == 0 ? Double(currentStepGoal) : Double(currentCalorieGoal)

        return VStack(spacing: 16) {
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(currentColor)
                            .frame(height: calculateBarHeight(for: values[index], goal: goal))

                        Text(weekdays[index])
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(Int(values[index]))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .background(isTodayIndex(index) ? Color.gray.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
                }
            }
            .frame(height: 180)
        }
    }

    private func calculateBarHeight(for value: Double, goal: Double) -> CGFloat {
        let maxHeight: CGFloat = 150
        let percentage = min(value / goal, 1.0)
        return max(20, maxHeight * CGFloat(percentage))
    }

    private func isTodayIndex(_ index: Int) -> Bool {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date())
        let todayIndex = today - 1
        return index == todayIndex
    }

    private func fetchCurrentWeekData() {
        let calendar = Calendar.current
        let today = Date()

        let todayComponents = calendar.dateComponents([.weekday], from: today)
        let currentWeekday = todayComponents.weekday ?? 1

        let daysToSunday = currentWeekday - 1

        weeklySteps = Array(repeating: 0, count: 7)
        weeklyCalories = Array(repeating: 0, count: 7)

        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -daysToSunday + i, to: today) {
                healthKitManager.fetchSteps(for: date) { steps in
                    weeklySteps[i] = Double(steps)
                }

                healthKitManager.fetchCalories(for: date) { calories in
                    weeklyCalories[i] = calories
                }
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let icon: String
    let color: Color
    let average: Int
    let goal: Int
    let completion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text("Avg: \(average)")
                .font(.title3)
                .fontWeight(.bold)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(completion) * geometry.size.width, geometry.size.width))
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

#Preview {
    WeeklyCalendarView(healthKitManager: HealthKitManager())
}
