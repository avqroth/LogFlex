//
//  EmptyWorkoutCard.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI

struct EmptyWorkoutCard: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("No workouts yet")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 35))
    }
}

#Preview {
    EmptyWorkoutCard()
}
