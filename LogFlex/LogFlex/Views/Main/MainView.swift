import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var greeting: String = ""
    @State private var progress: Double = 0.0
    @State private var steps: Int = 0
    @State private var showingHeartRateHistory = false
    @State private var isRefreshing = false
    @State private var isBeating = false
    
    @Query(sort: \WorkoutLog.date, order: .reverse) private var recentWorkouts: [WorkoutLog]
    @Environment(\.modelContext) private var modelContext

    var latestWorkout: WorkoutLog? {
        recentWorkouts.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Spacer(minLength: 0)

                HStack {
                    VStack {
                        HealthProgressCircle(healthKitManager: healthKitManager)
                    }
                    .padding()
                    .padding(.top)
                    .padding(.bottom, 20)
                }

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

                    HistoricalDataButton(healthKitManager: healthKitManager)
                        .padding(.horizontal)
                        .padding(.bottom, 20)

                    Text("Heart Rate")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    SimpleBeatingHeartView()
                        .padding(.bottom)

                    Text("Water Tracking")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    WaterTrackingView()
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .padding(.horizontal)
                .padding(.bottom, 25)
            }
            .refreshable {
                await refreshHealthData()
            }
            .onAppear {
                Task {
                    await refreshHealthData()
                }
            }
            .navigationTitle("Main")
            
        }
    }

    private var currentHeartRateCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
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

            SimpleBeatingHeartView()
                .padding(.trailing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }

    @MainActor
    private func refreshHealthData() async {
        isRefreshing = true

        do {
            try await Task.sleep(for: .milliseconds(500))

            await healthKitManager.fetchTodaySteps()
            await healthKitManager.fetchTodayCalories()
            await healthKitManager.fetchHeartRate()
            await healthKitManager.fetchMiles()
        } catch is CancellationError {
            print("Refresh operation was cancelled")
        } catch {
            print("Error during refresh: \(error)")
        }

        isRefreshing = false
    }
}
