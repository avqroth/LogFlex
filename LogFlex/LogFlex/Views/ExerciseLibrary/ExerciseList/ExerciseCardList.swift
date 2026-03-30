//
//  ExerciseCardList.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct ExerciseCardList: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        LazyVStack(spacing: 12) {
            ForEach($viewModel.filteredExercises) { $exercise in  // ✅ $exercise is Binding<Exercise>
                ExerciseCard(exercise: exercise, viewModel: viewModel)
                    .id("\(exercise.id)-\(exercise.isFavorite)")  // ✅ access via unwrapped exercise
            }
        }
    }
}
