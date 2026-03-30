//
//  FavoriteButton.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct FavoriteButton: View {
    let exercise: Exercise
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        Button(action: {
            viewModel.toggleFavorite(for: exercise)
        }) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 36)

                Image(systemName: viewModel.isExerciseFavorited(exercise) ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isExerciseFavorited(exercise) ? .red : .white)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
        .id(viewModel.isExerciseFavorited(exercise))
    }
}

