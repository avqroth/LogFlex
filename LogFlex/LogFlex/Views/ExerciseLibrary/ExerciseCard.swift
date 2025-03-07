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

    var body: some View {
        NavigationLink(destination: ExerciseDetailView(exercise: exercise)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(mainColor)

                    Text(exercise.name)
                        .font(.headline)

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


#Preview {
    ExerciseCard(exercise: Exercise(name: "", type: "", muscle: "", equipment: "", difficulty: "", instructions: ""))
}
