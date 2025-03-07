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
        .swimming
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
        // Calculate workout duration based on exercises
        let estimatedDuration: TimeInterval = 3600 // Default 1 hour, adjust as needed
        let workoutEndDate = selectedDate.addingTimeInterval(estimatedDuration)
        
        healthKitManager.fetchWorkoutHeartRate(start: selectedDate, end: workoutEndDate) { heartRate in
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
                averageHeartRate: Int(healthKitManager.heartRate)            )
            
            modelContext.insert(newWorkout)
            try? modelContext.save()
            
            showWorkoutSheet = false
            dismiss()
        }
    }
    
    struct ActivitySectionView: View {
        let section: ActivitySection
        @Binding var activitySections: [ActivitySection]
        
        var body: some View {
            Section {
                SectionHeader(
                    section: section,
                    activitySections: $activitySections
                )
                
                if section.type == .strength {
                    StrengthContent(
                        section: section,
                        activitySections: $activitySections
                    )
                } else {
                    CardioContent(
                        section: section,
                        activitySections: $activitySections
                    )
                }
            }
        }
    }
    
    struct SectionHeader: View {
        let section: ActivitySection
        @Binding var activitySections: [ActivitySection]
        
        var body: some View {
            HStack {
                Label(section.type.rawValue, systemImage: section.type.icon)
                Spacer()
                Button(action: {
                    if let index = activitySections.firstIndex(where: { $0.id == section.id }) {
                        activitySections.remove(at: index)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    struct StrengthContent: View {
        let section: ActivitySection
        @Binding var activitySections: [ActivitySection]

        var body: some View {
            ForEach(section.exercises.indices, id: \.self) { exerciseIndex in
                if let sectionIndex = activitySections.firstIndex(where: { $0.id == section.id }) {
                    let exercise = section.exercises[exerciseIndex]
                    VStack {
                        let workoutLog = WorkoutLog(
                            date: Date(),
                            name: exercise.name,
                            activityType: section.type
                        )
                        ExerciseRow(
                            exerciseMetrics: ActivityData(
                                type: section.type,
                                metrics: exercise.metrics
                            ),
                            exerciseName: workoutLog
                        )

                        MetricsInputs(
                            metrics: $activitySections[sectionIndex].exercises[exerciseIndex].metrics,
                            type: section.type,
                            showStrengthMetrics: true,
                            exerciseMetrics: exercise.metrics,
                            exerciseName: exercise.name
                        )
                    }
                }
            }
            if let index = activitySections.firstIndex(where: { $0.id == section.id }) {
                AddExerciseButton(exercises: $activitySections[index].exercises)
            }
        }
    }

    // Cardio content
    struct CardioContent: View {
        let section: ActivitySection
        @Binding var activitySections: [ActivitySection]
        
        var body: some View {
            if let index = activitySections.firstIndex(where: { $0.id == section.id }) {
                MetricsInputs(
                    metrics: $activitySections[index].metrics,
                    type: section.type,
                    showStrengthMetrics: false,
                    exerciseMetrics: ActivityMetrics(), exerciseName: ""
                )
            }
        }
    }
}

#Preview {
    CustomWorkout(showWorkoutSheet: .constant(true))
}

