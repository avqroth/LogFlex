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
        VStack {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
            } else if viewModel.showingFavoritesOnly && viewModel.filteredExercises.isEmpty {
                EmptyFavoritesView(onBrowseAll: {
                    viewModel.showingFavoritesOnly = false
                })
            } else {
                ExerciseCardList(viewModel: viewModel)
            }
        }
    }
}
