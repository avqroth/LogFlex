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

// MARK: - Supporting Detail Views

struct HeaderView: View {
    let exercise: Exercise

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(height: 300)

            VStack(spacing: 16) {
                Text(exercise.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

                DifficultyBadge(level: exercise.difficulty)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct FavoriteButton: View {
    let exercise: Exercise
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        Button(action: {
            viewModel.toggleFavorite(exercise)
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
struct BackButton: View {
    var dismiss: DismissAction

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            ZStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(value.capitalized)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct InstructionsCard: View {
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Instructions")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "text.append")
                    .foregroundColor(.blue)
            }

            Divider()

            Text(instructions)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
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
