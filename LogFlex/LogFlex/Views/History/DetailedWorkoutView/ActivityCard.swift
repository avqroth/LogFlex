//
//  ActivityCard.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct ActivityCard: View {
    let activity: ActivityData

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(activity.type.rawValue)
                .font(.title3)
                .fontWeight(.semibold)

            if activity.type == .strength {
                ForEach(activity.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        if !activity.metrics.sets.isEmpty &&
                           !activity.metrics.reps.isEmpty {
                            Text("\(activity.metrics.sets) sets • \(activity.metrics.reps) reps • \(activity.metrics.weight)lbs")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            // Display a fallback if metrics are empty
                            Text("No set/rep data")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.leading)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    if !activity.metrics.distance.isEmpty {
                        MetricRow(title: "Distance", value: "\(activity.metrics.distance) miles")
                    }
                    if !activity.metrics.duration.isEmpty {
                        MetricRow(title: "Duration", value: "\(activity.metrics.duration) min")
                    }
                    if !activity.metrics.laps.isEmpty {
                        MetricRow(title: "Laps", value: activity.metrics.laps)
                    }
                    if !activity.metrics.calories.isEmpty {
                        MetricRow(title: "Calories", value: "\(activity.metrics.calories) kcal")
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

