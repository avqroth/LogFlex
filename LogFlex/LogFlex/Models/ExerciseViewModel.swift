//
//  ExerciseView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import Foundation

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var searchText = ""
    @Published var selectedMuscle: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let exerciseService = ExerciseService()

    let muscleGroups = [
        "abdominals", "biceps", "calves", "chest",
        "forearms", "glutes", "hamstrings", "lats",
        "lower_back", "middle_back", "neck",
        "quadriceps", "traps", "triceps"
    ]

    func loadExercises() async {
        isLoading = true
        errorMessage = nil

        do {
            exercises = try await exerciseService.fetchExercises(
                muscle: selectedMuscle,
                name: searchText.isEmpty ? nil : searchText
            )
        } catch {
            errorMessage = "Failed to load exercises: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
