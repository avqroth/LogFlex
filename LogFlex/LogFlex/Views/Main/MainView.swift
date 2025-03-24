//
//  MainViewswift.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @StateObject private var circleViewModel = CircleViewModel()
    @State private var greeting: String = ""
    @State private var progress: Double = 0.0
    @State private var steps: Int = 0
    @State private var showingHeartRateHistory = false

    @Query(sort: \WorkoutLog.date, order: .reverse) private var recentWorkouts: [WorkoutLog]
    @Environment(\.modelContext) private var modelContext

    var latestWorkout: WorkoutLog? {
        recentWorkouts.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Spacer(minLength: 0)

                VStack {
                    HealthProgressCircle(healthKitManager: healthKitManager)
                }
                .padding()
                .padding(.top)
                .padding(.bottom, 50)

                VStack(alignment: .leading, spacing: 24) {
                    Text("Most Recent Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if let workout = latestWorkout {
                        NavigationLink(destination: DetailedWorkoutView(workout: workout)) {
                            WorkoutSummaryCard(workout: workout)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    } else {
                        EmptyWorkoutCard()
                            .padding(.horizontal)
                            .padding(.bottom)
                    }

                    Text("Activity History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top)

                    WeeklyCalendarView(healthKitManager: healthKitManager)
                        .padding(.horizontal)
                        .padding(.bottom)

                    Text("Heart Rate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    Button(action: {
                        showingHeartRateHistory = true
                    }) {
                        currentHeartRateCard
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                    .navigationDestination(isPresented: $showingHeartRateHistory) {
                        AppleStyleHeartRateView(healthKitManager: healthKitManager)
                    }

                    Text("Water Tracking")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    WaterTrackingView()
                        .padding(.horizontal)
                        .padding(.bottom)

                    //                    Text("Heart Rate History")
                    //                        .font(.title2)
                    //                        .fontWeight(.bold)
                    //                        .padding(.horizontal)

                    //                    WorkoutHeartRateGraph()
                    //                        .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
            .onAppear {
                healthKitManager.fetchTodaySteps()
                healthKitManager.fetchTodayCalories()
                healthKitManager.fetchHeartRate()
            }
            .onChange(of: healthKitManager.caloriesBurned) {
                circleViewModel.updateCalories(healthKitManager.caloriesBurned)
            }
            .onChange(of: healthKitManager.milesWalked) {
                circleViewModel.updateMiles(healthKitManager.milesWalked)
            }
            .onChange(of: healthKitManager.heartRate) {
                circleViewModel.updateHeartRate(healthKitManager.heartRate)
            }
            .navigationTitle("Main")
        }
    }

    private var currentHeartRateCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(Int(healthKitManager.heartRate))")
                        .font(.system(size: 44, weight: .bold))
                    + Text(" BPM")
                        .font(.headline)
                        .foregroundColor(.gray)
                }

                    Text("Current Heart Rate")
                        .font(.subheadline)
                        .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.title2)
                .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}



#Preview {
    MainView()
        .environmentObject(HealthKitManager())
}
