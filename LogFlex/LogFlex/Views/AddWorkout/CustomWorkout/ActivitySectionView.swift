//
//  ActivitySectionView.swift
//  LogFlex
//
//  Created by Avery Roth on 3/10/25.
//

import SwiftUI

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
                        metrics: $activitySections[sectionIndex].metrics,
                        type: section.type,
                        showStrengthMetrics: true,
                        exerciseMetrics: ActivityMetrics(),
                        exerciseName: ""
                    )
                }
            }
        }
        if let index = activitySections.firstIndex(where: { $0.id == section.id }) {
            AddExerciseButton(exercises: $activitySections[index].exercises)
        }
    }
}

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

