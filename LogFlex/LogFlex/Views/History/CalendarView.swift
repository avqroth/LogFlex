


import SwiftUI
import SwiftData

struct CalendarView: View {
    @State private var color = Color.main
    let backup = Color.backup
    let accent = Color.accent
    @State private var date = Date.now
    @State private var selectedDate: Date?
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    var selectedActivityType: ActivityType?

    // Query all workouts
    @Query var workoutLogs: [WorkoutLog]

    // Filter workouts based on date and activity type
    private func workoutsForDate(_ date: Date) -> [WorkoutLog] {
        var filtered = workoutLogs.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }

        if let activityType = selectedActivityType {
            filtered = filtered.filter { $0.activityType == activityType }
        }

        return filtered
    }

    private func hasWorkouts(_ date: Date) -> Bool {
        !workoutsForDate(date).isEmpty
    }

    var body: some View {
        // Rest of your view remains the same
        VStack {
            VStack {
                LabeledContent("Date/Time") {
                    DatePicker("", selection: $date)
                }
                .padding()

                HStack {
                    ForEach(daysOfWeek.indices, id: \.self) { index in
                        Text(daysOfWeek[index])
                            .font(.headline)
                            .foregroundStyle(.main)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns) {
                    ForEach(days, id: \.self) { day in
                        if day.monthInt != date.monthInt {
                            Text("")
                        } else {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            backgroundColorFor(day)
                                        )
                                )
                                .overlay(
                                    Circle()
                                        .stroke(hasWorkouts(day) ? color : .clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedDate = day
                                }
                        }
                    }
                }
            }

            if let selectedDate = selectedDate {
                let dateWorkouts = workoutsForDate(selectedDate)

                VStack(alignment: .leading, spacing: 15) {
                    Text(selectedDate.formatted(date: .long, time: .omitted))
                        .font(.title)

                    if dateWorkouts.isEmpty {
                        Text("No \(selectedActivityType?.rawValue ?? "workouts") on this date")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        ForEach(dateWorkouts) { workout in
                            WorkoutSummaryView(workout: workout)
                        }
                    }
                }
                .padding(.top)
            }
        }
        .onAppear {
            days = date.calendarDisplayDays
        }
        .onChange(of: date) {
            days = date.calendarDisplayDays
        }
    }

    private func backgroundColorFor(_ day: Date) -> Color {
        if Date.now.startOfDay == day.startOfDay {
            return accent
        } else if selectedDate?.startOfDay == day.startOfDay {
            return color.opacity(0.3)
        } else {
            return .main.opacity(0.0)
        }
    }
}
