//
//  ExerciseContentView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct ExerciseContentView: View {
    @ObservedObject var viewModel: ExerciseViewModel
    let mainColor: Color

    var body: some View {
        VStack(spacing: 0) {
            // Custom Segmented Control
            FavoritesTabView(showingFavoritesOnly: $viewModel.showingFavoritesOnly, viewModel: viewModel)
                            .padding(.horizontal)
                            .padding(.top)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom)

            ScrollView {
                VStack(spacing: 16) {
                    // Search and Filter section
                    if !viewModel.showingFavoritesOnly {
                        SearchFilterBar(viewModel: viewModel, mainColor: mainColor)
                            .padding(.horizontal)
                            .padding(.top)
                    }

                    // Exercise list content
                    ExerciseListContent(viewModel: viewModel)
                        .padding(.horizontal)
                }
            }
            .onChange(of: viewModel.searchText) { _ in
                Task { await viewModel.loadExercises() }
            }
            .onChange(of: viewModel.selectedMuscle) { _ in
                Task { await viewModel.loadExercises() }
            }
        }
    }
}

