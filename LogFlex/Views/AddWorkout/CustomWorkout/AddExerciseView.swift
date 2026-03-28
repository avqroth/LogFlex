//
//  AddExerciseView.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Binding var exercises: [ExerciseLog]
    @StateObject private var viewModel = ExerciseViewModel()
    @State private var selectedExercises: Set<String> = []
    let mainColor = Color.main

    var body: some View {
        NavigationView {
            VStack {
                // Search and Filter Bar
                HStack {
                    // Search Field
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search exercises", text: $viewModel.searchText)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(18)

                    // Muscle Filter Menu
                    Menu {
                        Button("All Muscles", action: { viewModel.selectedMuscle = nil })
                        ForEach(viewModel.muscleGroups, id: \.self) { muscle in
                            Button(muscle.capitalized) {
                                viewModel.selectedMuscle = muscle
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(mainColor)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.exercises) { exercise in
                                exerciseRow(exercise)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Select Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addAndDismiss()
                    }
                    .disabled(selectedExercises.isEmpty)
                }
            }
            .onChange(of: viewModel.searchText) { _ in
                Task { await viewModel.loadExercises() }
            }
            .onChange(of: viewModel.selectedMuscle) { _ in
                Task { await viewModel.loadExercises() }
            }
            .task { await viewModel.loadExercises() }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                if selectedExercises.contains(exercise.name) {
                    selectedExercises.remove(exercise.name)
                } else {
                    selectedExercises.insert(exercise.name)
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                        .foregroundStyle(mainColor)
                    Text(exercise.muscle.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                if selectedExercises.contains(exercise.name) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(mainColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
    }

    private func addAndDismiss() {
        selectedExercises.forEach { name in
            if let exercise = viewModel.exercises.first(where: { $0.name == name }) {
                let exerciseLog = ExerciseLog(name: exercise.name, metrics: ActivityMetrics())
                exercises.append(exerciseLog)
                modelContext.insert(exerciseLog)
            }
        }
        dismiss()
    }
}
