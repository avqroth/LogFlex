//
//  ExerciseListContent.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct ExerciseListContent: View {
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.exercises.isEmpty {
                loadingView
            } else if viewModel.hasError {
                errorView
            } else if viewModel.filteredExercises.isEmpty {
                emptyStateView
            } else {
                exerciseList
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
        .animation(.easeInOut(duration: 0.3), value: viewModel.hasError)
        .animation(.easeInOut(duration: 0.3), value: viewModel.filteredExercises.isEmpty)
    }

    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.main)

            Text("Loading exercises...")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text(viewModel.errorMessage ?? "Something went wrong")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    await viewModel.loadExercises()
                }
            } label: {
                Text("Try Again")
                    .fontWeight(.medium)
                    .frame(width: 120, height: 40)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 60))
                .foregroundColor(Color.main.opacity(0.7))

            if viewModel.showingFavoritesOnly {
                Text("No favorites yet")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("Add exercises to your favorites")
                    .foregroundColor(.secondary)
            } else {
                Text("No exercises found")
                    .font(.title3)
                    .fontWeight(.medium)

                Text("Try adjusting your search or filters")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .padding()
    }

    private var exerciseList: some View {
        LazyVStack(spacing: 16) {
            ForEach(viewModel.filteredExercises) { exercise in
                ExerciseCard(exercise: exercise, viewModel: viewModel)
            }
        }
        .padding(.bottom, 16)
        .overlay(alignment: .top) {
            if viewModel.isLoading && !viewModel.filteredExercises.isEmpty {
                ProgressView()
                    .tint(Color.main)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .padding(.top, 10)
            }
        }
    }
}
