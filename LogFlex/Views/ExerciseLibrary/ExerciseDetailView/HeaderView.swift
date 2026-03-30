//
//  HeaderView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct HeaderView: View {
    let exercise: Exercise

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .frame(height: 300)

            VStack(spacing: 16) {
                Text(exercise.name)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

                DifficultyBadge(level: exercise.difficulty)
                    .padding(.bottom, 40)
            }
        }
    }
}

