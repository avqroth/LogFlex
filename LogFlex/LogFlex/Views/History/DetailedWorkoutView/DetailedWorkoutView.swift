//
//  DetailedWorkoutView.swift
//  LogFlex
//
//  Created by Avery Roth on 1/21/25.
//

import SwiftUI

struct DetailedWorkoutView: View {
    let workout: WorkoutLog
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        Text(workout.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.accent)
                            .multilineTextAlignment(.center)

                        HStack {
                            Label(workout.activityType.rawValue, systemImage: "figure.run")
                            Divider()
                                .frame(height: 20)
                            Label(workout.date.formatted(date: .abbreviated, time: .omitted),
                                  systemImage: "calendar")
                        }
                        .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()

                    if !workout.activities.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Activities")
                                .font(.headline)
                                .foregroundStyle(.accent)

                            ForEach(workout.activities) { activity in
                                ActivityCard(activity: activity)
                            }
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
