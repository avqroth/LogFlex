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
    @Published var favoriteExercises: [Exercise] = []
    @Published var hasError = false
    @Published var errorMessage: String?

    private let networkManager = NetworkManager()
    private let exerciseService = ExerciseService()

    var muscleGroups: [String] = [
        "abdominals", "biceps", "calves", "chest",
        "forearms", "glutes", "hamstrings", "lats",
        "lower_back", "middle_back", "neck", "quadriceps",
        "shoulders", "traps", "triceps"
    ]

    @MainActor
    func loadExercises() async {
        isLoading = true
        hasError = false
        errorMessage = nil

        do {
            exercises = try await exerciseService.fetchExercises(
                muscle: selectedMuscle,
                name: searchText.isEmpty ? nil : searchText
            )
        } catch let error as NetworkError {
            hasError = true
            errorMessage = error.localizedDescription
            exercises = []
        } catch {
            hasError = true
            errorMessage = "Failed to load exercises: \(error.localizedDescription)"
            exercises = []
        }

        isLoading = false
    }
    
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

    func addToFavorites(_ exercise: Exercise) {
            if !isExerciseFavorited(exercise) {
                favoriteExercises.append(exercise)
                saveFavorites()
                objectWillChange.send()
            }
        }

    func removeFromFavorites(_ exercise: Exercise) {
            favoriteExercises.removeAll { $0.name == exercise.name }
            saveFavorites()
            objectWillChange.send()
        }

        func toggleFavorite(_ exercise: Exercise) {
            if isExerciseFavorited(exercise) {
                removeFromFavorites(exercise)
            } else {
                addToFavorites(exercise)
            }
            refreshFavorites()
        }

        func refreshFavorites() {
            loadFavorites()
            objectWillChange.send()
        }

    func isExerciseFavorited(_ exercise: Exercise) -> Bool {
        return favoriteExercises.contains { $0.name == exercise.name }
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteExercises) {
            UserDefaults.standard.set(encoded, forKey: "favoriteExercises")
            UserDefaults.standard.synchronize()

        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: "favoriteExercises"),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            favoriteExercises = decoded
        }
    }

    init() {
        loadFavorites()
        Task {
            await loadExercises()
        }
    }
}
