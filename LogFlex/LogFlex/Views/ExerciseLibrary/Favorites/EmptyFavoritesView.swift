//
//  EmptyFavoritesView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct EmptyFavoritesView: View {
    let onBrowseAll: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.bottom)

            Text("No Favorite Exercises")
                .font(.title2)
                .fontWeight(.bold)

            Text("Tap the heart icon on exercises you like to add them to your favorites.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: onBrowseAll) {
                Text("Browse All Exercises")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

