//
//  Cardio.swift
//  LogFlex
//
//  Created by Avery Roth on 11/29/24.
//

import SwiftUI
import HealthKit

struct Cardio: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedActivity: ActivityType = .running
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWorkout: CardioType?
    @State private var workoutName = ""
    @State private var duration: TimeInterval = 0
    @State private var isTimerRunning = false
    @State private var selectedDate = Date()

    let mainColor = Color.main
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    enum CardioType: String, CaseIterable {
        case running = "Running"
        case cycling = "Cycling"
        case swimming = "Swimming"
        case rowing = "Rowing"
        case jumpRope = "Jump Rope"
        case hiking = "Hiking"

        var icon: String {
            switch self {
            case .running: return "figure.run"
            case .cycling: return "figure.outdoor.cycle"
            case .swimming: return "figure.pool.swim"
            case .rowing: return "figure.rowing"
            case .jumpRope: return "figure.jumprope"
            case .hiking: return "figure.hiking"
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Picker
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(mainColor)
                        DatePicker(
                            "Workout Date",
                            selection: $selectedDate,
                            in: ...Date(),
                            displayedComponents: [.date]
                        )
                    }
                    .padding()

                    // Workout Name
                    HStack {
                        TextField("Workout Name", text: $workoutName)
                            .padding(10)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Workout Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(CardioType.allCases, id: \.self) { workout in
                            WorkoutCard(
                                type: workout,
                                isSelected: selectedWorkout == workout,
                                action: { selectedWorkout = workout }
                            )
                        }
                    }
                    .padding()

                    if let workout = selectedWorkout {
                        VStack(spacing: 16) {
                            // Timer display
                            Text(timeString(from: duration))
                                .font(.system(size: 60, weight: .bold, design: .monospaced))
                                .foregroundColor(mainColor)

                            // Distance and heart rate
                            if healthManager.isTrackingWorkout {
                                HStack(spacing: 20) {
                                    StatView(
                                        value: String(format: "%.2f", healthManager.activeWorkoutDistance),
                                        unit: "mi",
                                        icon: "figure.walk"
                                    )

                                    StatView(
                                        value: "\(Int(healthManager.heartRate))",
                                        unit: "bpm",
                                        icon: "heart.fill"
                                    )

                                    StatView(
                                        value: "\(Int(healthManager.caloriesBurned))",
                                        unit: "cal",
                                        icon: "flame.fill"
                                    )
                                }
                            }

                            // Controls
                            HStack(spacing: 30) {
                                Button(action: {
                                    isTimerRunning.toggle()
                                    if isTimerRunning {
                                        let workoutType = healthKitWorkoutType(for: workout)
                                        healthManager.startWorkoutTracking(for: workoutType)
                                    } else {
                                        healthManager.stopWorkoutTracking()
                                    }
                                }) {
                                    Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(mainColor)
                                }

                                Button(action: {
                                    resetTimer()
                                    healthManager.stopWorkoutTracking()
                                }) {
                                    Image(systemName: "stop.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(mainColor)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .padding()
                    }
                }
            }
            .navigationBarItems(
                leading: Button("Cancel") {
                    healthManager.stopWorkoutTracking()
                    dismiss()
                },
                trailing: Button("Save") {
                    saveWorkout()
                    healthManager.stopWorkoutTracking()
                    dismiss()
                }
                    .disabled(workoutName.isEmpty || selectedWorkout == nil || duration == 0)
            )
            .navigationTitle("Cardio")

        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if isTimerRunning {
                duration += 1
            }
        }
    }

    private func stopTimer() {
        isTimerRunning = false
    }

    private func resetTimer() {
        isTimerRunning = false
        duration = 0
    }

    private func timeString(from duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    private func healthKitWorkoutType(for workout: CardioType) -> HKWorkoutActivityType {
        switch workout {
        case .running:
            return .running
        case .cycling:
            return .cycling
        case .swimming:
            return .swimming
        case .rowing:
            return .rowing
        case .jumpRope:
            return .jumpRope
        case .hiking:
            return .hiking
        }
    }

    func saveWorkout() {
        guard selectedWorkout != nil else { return }

        // Create activity metrics
        let metrics = ActivityMetrics(
            distance: String(format: "%.2f", healthManager.activeWorkoutDistance),
            duration: String(format: "%.0f", duration),
            calories: String(Int(healthManager.caloriesBurned)),
            sets: "",  // No sets for cardio
            reps: "",  // No reps for cardio
            weight: ""
        )

        // Create activity data
        let activity = ActivityData(
            type: selectedActivity,
            exercises: [],
            metrics: metrics
        )

        let newWorkout = WorkoutLog(
            date: selectedDate,
            name: workoutName,
            activityType: selectedActivity,
            activities: [activity],
            exercises: [],
            distance: healthManager.activeWorkoutDistance,
            duration: duration,
            laps: 0,
            pace: healthManager.activeWorkoutDistance > 0 ? duration / healthManager.activeWorkoutDistance : 0
        )

        modelContext.insert(newWorkout)
        try? modelContext.save()

        healthManager.stopWorkoutTracking()
        dismiss()
    }
}





#Preview {
    Cardio()
        .environmentObject(HealthKitManager())
}
