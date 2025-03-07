//
//  Capsules.swift
//  LogFlex
//
//  Created by Avery Roth on 10/8/24.
//

import Foundation
import SwiftUI

struct WorkoutOption: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    let color: Color
}

struct WorkoutGridView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWorkout: WorkoutOption?
    @State private var showWorkoutView = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    let workouts = [
        WorkoutOption(name: "Strength", systemImage: "dumbbell.fill", color: .blue),
        WorkoutOption(name: "Cardio", systemImage: "heart.fill", color: .red),
        WorkoutOption(name: "HIIT", systemImage: "flame.fill", color: .orange),
        WorkoutOption(name: "Yoga", systemImage: "figure.mind.and.body", color: .purple)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(workouts) { workout in
                    Button(action: {
                        selectedWorkout = workout
                        showWorkoutView = true
                    }) {
                        VStack {
                            Image(systemName: workout.systemImage)
                                .font(.system(size: 30))
                                .foregroundColor(workout.color)
                                .padding(.bottom, 5)

                            Text(workout.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(workout.color.opacity(0.1))
                        )
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showWorkoutView) {
            if let workout = selectedWorkout {
                NavigationView {
                    getWorkoutView(for: workout)
                }
            }
        }
    }

    @ViewBuilder
    func getWorkoutView(for workout: WorkoutOption) -> some View {
        switch workout.name {
        case "Strength":
            Strength()
        case "Cardio":
            Cardio()
        case "HIIT":
            HIIT()
        case "Yoga":
            Yoga()
        default:
            Text("Workout not found")
        }
    }
}
