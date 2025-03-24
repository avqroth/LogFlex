//
//  WorkoutSummaryCard.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI

struct WorkoutSummaryCard: View {
    let workout: WorkoutLog

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.accent)

                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Color.accent)
                        .padding(.top, 15)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
