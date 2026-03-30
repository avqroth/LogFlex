import SwiftUI
import SwiftData
import Charts

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
    @State private var rawSelectedDate: Date?
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

    private var totalSteps: Int {
        Int(weeklySteps.reduce(0, +))
    }

    private var totalCalories: Int {
        Int(weeklyCalories.reduce(0, +))
    }

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 25) {
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
                    .padding(.top)

                Text("Total: \(selectedTab == 0 ? totalSteps : totalCalories)")
                    .fontWeight(.semibold)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.bottom)

                chartsWeeklyView()
                    .padding(.bottom)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .onAppear {
            fetchCurrentWeekData()
        }
    }

    private func chartsWeeklyView() -> some View {
        let currentColor = selectedTab == 0 ? Color.stand : Color.accent
        let values = selectedTab == 0 ? weeklySteps : weeklyCalories
        let title = selectedTab == 0 ? "Steps" : "Calories"

        return Chart {
            ForEach(0..<7, id: \.self) { index in
                BarMark(
                    x: .value("Day", weekdays[index]),
                    y: .value(title, values[index])
                )
                .foregroundStyle(currentColor.gradient)
            }
        }
        .frame(height: 180)
        .chartXSelection(value: $rawSelectedDate)
        .onChange(of: rawSelectedDate, { oldValue, newValue in print(newValue!)
        })
        .chartXAxis {
            AxisMarks {
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks {
                AxisValueLabel()
                AxisGridLine()
            }
        }
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

#Preview {
    WeeklyCalendarView(healthKitManager: HealthKitManager())
}
