//
//  ExerciseFavoritesManager.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import Foundation
import Combine

// Manager for handling exercise favorites
class ExerciseFavoritesManager: ObservableObject {
    @Published var favoritedExercises: [Exercise] = []
    private let favoritesKey = "favoritedExercises"

    init() {
        loadFavorites()
    }

    // Check if an exercise is favorited
    func isExerciseFavorited(_ exercise: Exercise) -> Bool {
        return favoritedExercises.contains { $0.name == exercise.name }
    }

    // Toggle favorite status of an exercise
    func toggleFavorite(_ exercise: Exercise) {
        if isExerciseFavorited(exercise) {
            favoritedExercises.removeAll { $0.name == exercise.name }
        } else {
            favoritedExercises.append(exercise)
        }
        saveFavorites()
        // Explicitly send objectWillChange notification
        objectWillChange.send()
    }

    // Save favorites to UserDefaults
    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoritedExercises) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    // Load favorites from UserDefaults
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            favoritedExercises = decoded
        }
    }
}
