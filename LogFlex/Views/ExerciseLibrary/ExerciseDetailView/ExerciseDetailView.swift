//
//  ExerciseDetailView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    @ObservedObject var viewModel: ExerciseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderView(exercise: exercise)

                VStack(spacing: 24) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        InfoCard(title: "Muscle", value: exercise.muscle, icon: "figure.strengthtraining.traditional")
                        InfoCard(title: "Equipment", value: exercise.equipment, icon: "dumbbell.fill")
                        InfoCard(title: "Type", value: exercise.type, icon: "figure.run")
                        InfoCard(title: "Difficulty", value: exercise.difficulty, icon: "chart.bar.fill")
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    InstructionsCard(instructions: exercise.instructions)
                        .padding(.bottom)

                }
                .background(Color(.systemBackground))
                .cornerRadius(30, corners: [.topLeft, .topRight, .bottomLeft, .bottomRight])
                .offset(y: -30)
            }
        }
        .background(
            LinearGradient(colors: [.stand.opacity(0.7), .accent.opacity(0.8)],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
        )
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackButton(dismiss: dismiss)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                FavoriteButton(exercise: exercise, viewModel: viewModel)
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


#Preview {
    NavigationView {
        ExerciseDetailView(
            exercise: Exercise(
                name: "Barbell Bench Press",
                type: "Strength",
                muscle: "Chest",
                equipment: "Barbell",
                difficulty: "intermediate",
                instructions: "Lie on your back on a flat bench. Grip a barbell with hands slightly wider than shoulder width. The bar should be directly over your shoulders. Unrack the bar by straightening your arms. Lower the bar to your mid-chest. Press the bar back to the starting position by extending your arms. Lock your elbows at the top of the movement before beginning another repetition."
            ),
            viewModel: ExerciseViewModel()
        )
    }
}
