//
//  ExerciseCard.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseCard: View {
    let exercise: Exercise
    let mainColor = Color.main
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        NavigationLink(destination: ExerciseDetailView(exercise: exercise, viewModel: ExerciseViewModel())) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(mainColor)

                    Text(exercise.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)

                    Spacer()

                    DifficultyBadge(level: exercise.difficulty)
                }

                HStack {
                    ExerciseTag(text: exercise.muscle.capitalized, icon: "figure.strengthtraining.traditional")
                    ExerciseTag(text: exercise.equipment.capitalized, icon: "gym.bag.fill")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
