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

                    Text(workout.date.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: workout.activityType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}
