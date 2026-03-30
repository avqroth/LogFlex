//
//  ExerciseViewModel.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class ExerciseViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var filteredExercises: [Exercise] = []  
    @Published var searchText: String = ""
    @Published var selectedMuscle: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingFavoritesOnly: Bool = false

    private let networkManager = NetworkManager()
    private lazy var exerciseService = ExerciseService(networkManager: networkManager)

    var hasError: Bool {
        errorMessage != nil
    }
    
    let muscleGroups: [String] = [
        "abdominals",
        "abductors",
        "adductors",
        "biceps",
        "calves",
        "chest",
        "forearms",
        "glutes",
        "hamstrings",
        "lats",
        "lower_back",
        "middle_back",
        "neck",
        "quadriceps",
        "traps",
        "triceps"
    ]

    func applyFilters() {
        filteredExercises = exercises.filter { exercise in
            let matchesSearch = searchText.isEmpty ||
                exercise.name.localizedCaseInsensitiveContains(searchText)
            let matchesMuscle = selectedMuscle.isEmpty ||
                exercise.muscle.localizedCaseInsensitiveContains(selectedMuscle)
            let matchesFavorites = !showingFavoritesOnly || exercise.isFavorite  // ✅ Add this

            return matchesSearch && matchesMuscle && matchesFavorites
        }
    }

    func isExerciseFavorited(_ exercise: Exercise) -> Bool {
        exercise.isFavorite
    }

    func toggleFavorite(for exercise: Exercise) {
        guard let index = exercises.firstIndex(where: { $0.id == exercise.id }) else { return }
        exercises[index].isFavorite.toggle()
        applyFilters() // keep filteredExercises in sync
    }

    func loadExercises(muscle: String? = nil, name: String? = nil) async {
        isLoading = true
        errorMessage = nil
        
        print("📋 Full Info.plist dump:")
        Bundle.main.infoDictionary?.forEach { print("   \($0.key): \($0.value)") }
        print("🏋️ loadExercises called — muscle: \(muscle ?? "nil"), name: \(name ?? "nil")")

        do {
            exercises = try await exerciseService.fetchExercises(muscle: muscle, name: name)
            print("✅ Loaded \(exercises.count) exercises")
            applyFilters()
            print("✅ Filtered to \(filteredExercises.count) exercises")
        } catch let error as NetworkError {
            errorMessage = error.errorDescription
            print("❌ NetworkError: \(error.errorDescription ?? "unknown")")
        } catch {
            errorMessage = "Unexpected error: \(error.localizedDescription)"
            print("❌ Unknown error: \(error)")
        }

        isLoading = false
    }

    func refreshFavorites() {
        showingFavoritesOnly = true
        applyFilters()
    }


}
