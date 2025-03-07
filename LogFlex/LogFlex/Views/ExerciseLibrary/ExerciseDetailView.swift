//
//  ExerciseDetailView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    let mainColor = Color.main

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 50))
                        .foregroundColor(mainColor)

                    DifficultyBadge(level: exercise.difficulty)
                }
                .padding()

                // Info Cards
                VStack(spacing: 16) {
                    infoCard("Muscle", value: exercise.muscle, icon: "figure.strengthtraining.traditional")
                    infoCard("Equipment", value: exercise.equipment, icon: "gym.bag.fill")
                    infoCard("Type", value: exercise.type, icon: "figure.run")
                }
                .padding(.horizontal)

                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Instructions")
                        .font(.headline)

                    Text(exercise.instructions)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
        .background(
            LinearGradient(colors: [.backup, .accent], startPoint: .trailing, endPoint: .bottom)
        )
    }

    private func infoCard(_ title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(mainColor)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value.capitalized)
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ExerciseDetailView(exercise: Exercise(name: "", type: "", muscle: "", equipment: "", difficulty: "", instructions: ""))
}
