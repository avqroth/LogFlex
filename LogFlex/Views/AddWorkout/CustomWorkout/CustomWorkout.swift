//
//  CustomWorkout.swift
//  LogFlex
//
//  Created by Avery Roth on 12/10/24.
//

import SwiftUI
import SwiftData

struct CustomWorkout: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var healthKitManager: HealthKitManager
    @Binding var showWorkoutSheet: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName = ""
    @State private var activitySections: [ActivitySection] = []
    @State private var showingActivityPicker = false
    @State private var selectedDate = Date()
    @State private var currentWeight = ""
    @State private var currentReps = ""
    let mainColor = Color.main
    
    private let cardioActivities: [ActivityType] = [
        .running,
        .cycling,
        .swimming,
        .rowing
    ]
    
    var body: some View {
        Form {
            Section {
                DatePicker(
                    "Workout Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                TextField("Workout Name", text: $workoutName)
            }
            
            ForEach(activitySections) { section in
                ActivitySectionView(
                    section: section,
                    activitySections: $activitySections
                )
            }
            Section {
                Button(action: { showingActivityPicker = true }) {
                    Label("Add Activity", systemImage: "plus")
                        .foregroundStyle(mainColor)
                }
            }
        }
        .sheet(isPresented: $showingActivityPicker) {
            ActivityPickerView { selectedType in
                activitySections.append(ActivitySection(
                    type: selectedType,
                    exercises: [],
                    metrics: ActivityMetrics()
                ))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    showWorkoutSheet = false
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task {
                        await saveWorkout()
                    }
                }
                .disabled(workoutName.isEmpty || activitySections.isEmpty)
            }
        }
        .navigationTitle("Add Workout")
    }
    
    private func saveWorkout() async {
        let estimatedDuration: TimeInterval = 3600
        let workoutEndDate = selectedDate.addingTimeInterval(estimatedDuration)
        
        await healthKitManager.fetchHeartRateAsync(start: selectedDate, end: workoutEndDate)
        
        let activities = activitySections.map { section in
            ActivityData(
                type: section.type,
                exercises: section.exercises,
                metrics: section.metrics
            )
        }
        
        let newWorkout = WorkoutLog(
            date: selectedDate,
            name: workoutName,
            activityType: activitySections.first?.type ?? .other,
            activities: activities,
            exercises: [],
            distance: nil,
            duration: estimatedDuration,
            laps: nil,
            pace: nil,
            averageHeartRate: Int(healthKitManager.heartRate),
            exerciseMetrics: nil
        )
        
        await MainActor.run {
            modelContext.insert(newWorkout)
            try? modelContext.save()
            
            showWorkoutSheet = false
            dismiss()
        }
    }
}

extension HealthKitManager {
    func fetchHeartRateAsync(start: Date, end: Date) async {
        return await withCheckedContinuation { continuation in
            self.fetchWorkoutHeartRate(start: start, end: end) { heartRate in
                continuation.resume()
            }
        }
    }
}

#Preview {
    CustomWorkout(showWorkoutSheet: .constant(true))
}

