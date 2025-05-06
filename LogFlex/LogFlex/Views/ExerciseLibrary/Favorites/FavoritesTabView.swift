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
                withAnimation(.spring()) {
                    showingFavoritesOnly = false
                }
            }

            TabButton(title: "Favorites", isSelected: showingFavoritesOnly) {
                withAnimation(.spring()) {
                    showingFavoritesOnly = true
                    // Force refresh when showing favorites
                    viewModel.objectWillChange.send()
                }
            }
        }
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

