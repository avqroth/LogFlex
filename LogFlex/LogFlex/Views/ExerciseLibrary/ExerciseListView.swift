//
//  ExerciseListView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject var viewModel = ExerciseViewModel()
    let mainColor = Color.main

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
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
                        ProgressView()
                            .padding()
                    } else {
                        // Exercise Cards
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.exercises) { exercise in
                                ExerciseCard(exercise: exercise)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Exercise Library")
            .refreshable { await viewModel.loadExercises() }
            .onChange(of: viewModel.searchText) { _ in
                Task { await viewModel.loadExercises() }
            }
            .onChange(of: viewModel.selectedMuscle) { _ in
                Task { await viewModel.loadExercises() }
            }
        }
    }
}

#Preview {
    ExerciseListView()
}
