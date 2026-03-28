//
//  FavoritesTabView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct FavoritesTabView: View {
    @Binding var showingFavoritesOnly: Bool
    @ObservedObject var viewModel: ExerciseViewModel

    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "All Exercises", isSelected: !showingFavoritesOnly) {
                showingFavoritesOnly = false

            }

            TabButton(title: "Favorites", isSelected: showingFavoritesOnly) {
                viewModel.refreshFavorites()

                showingFavoritesOnly = true
            }
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(18)
        .onChange(of: showingFavoritesOnly) { oldValue, newValue in
            if newValue == true {
                viewModel.refreshFavorites()
            }
        }
    }
}
