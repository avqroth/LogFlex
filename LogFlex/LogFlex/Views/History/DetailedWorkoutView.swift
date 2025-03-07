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
                    // Header Section
                    VStack(spacing: 12) {
                        Text(workout.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.main)
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

                    // Activities Section
                    if !workout.activities.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Activities")
                                .font(.headline)
                                .foregroundStyle(.main)

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("\(value)\(unit.isEmpty ? "" : " \(unit)")")
                .font(.title3)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

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

                        Text("\(activity.metrics.sets) sets • \(activity.metrics.reps) reps • \(activity.metrics.weight)lbs")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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

struct MetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}
