//
//  ExerciseViewModel.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import Foundation
import SwiftUI
import Combine

class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedMuscle: String? = nil
    @Published var showingFavoritesOnly = false
    @Published var favoriteExercises: [Exercise] = [] // Published array of favorite exercises

    private let exerciseService = ExerciseService()

    var muscleGroups: [String] = [
        "abdominals", "biceps", "calves", "chest",
        "forearms", "glutes", "hamstrings", "lats",
        "lower_back", "middle_back", "neck", "quadriceps",
        "shoulders", "traps", "triceps"
    ]

    // Computed property to get appropriate exercises
    var filteredExercises: [Exercise] {
        if showingFavoritesOnly {
            return favoriteExercises
        } else {
            if let muscle = selectedMuscle, !muscle.isEmpty {
                return exercises.filter { $0.muscle.lowercased() == muscle.lowercased() }
            }
            if !searchText.isEmpty {
                return exercises.filter { $0.name.lowercased().contains(searchText.lowercased()) }
            }
            return exercises
        }
    }

    // Add to favorites
    func addToFavorites(_ exercise: Exercise) {
        if !isExerciseFavorited(exercise) {
            favoriteExercises.append(exercise)
            saveFavorites()
        }
    }

    // Remove from favorites
    func removeFromFavorites(_ exercise: Exercise) {
        favoriteExercises.removeAll { $0.name == exercise.name }
        saveFavorites()
    }

    // Toggle favorite
    func toggleFavorite(_ exercise: Exercise) {
        if isExerciseFavorited(exercise) {
            removeFromFavorites(exercise)
        } else {
            addToFavorites(exercise)
        }
        // Force UI update
        objectWillChange.send()
    }

    // Check if favorited
    func isExerciseFavorited(_ exercise: Exercise) -> Bool {
        return favoriteExercises.contains { $0.name == exercise.name }
    }

    // Save favorites to UserDefaults
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteExercises) {
            UserDefaults.standard.set(encoded, forKey: "favoriteExercises")
        }
    }

    // Load favorites from UserDefaults
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favoriteExercises"),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            favoriteExercises = decoded
        }
    }

    // Load exercises from API
    @MainActor
    func loadExercises() async {
        isLoading = true

        do {
            exercises = try await exerciseService.fetchExercises(
                muscle: selectedMuscle,
                name: searchText.isEmpty ? nil : searchText
            )
        } catch {
            print("Error fetching exercises: \(error.localizedDescription)")
        }

        isLoading = false
    }

    init() {
        loadFavorites()
        Task {
            await loadExercises()
        }
    }
}
