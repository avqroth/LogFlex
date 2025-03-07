//
//  ExerciseRow.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import SwiftUI

struct ExerciseRow: View {
    let exerciseMetrics: ActivityData
    let exerciseName: WorkoutLog

    init(exerciseMetrics: ActivityData, exerciseName: WorkoutLog) {
        self.exerciseMetrics = exerciseMetrics
        self.exerciseName = exerciseName
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(exerciseName.name)
                .font(.headline)
            Text("\(exerciseMetrics.metrics.weight)lbs × \(exerciseMetrics.metrics.reps) reps")
                .foregroundStyle(.secondary)
        }
    }
}

