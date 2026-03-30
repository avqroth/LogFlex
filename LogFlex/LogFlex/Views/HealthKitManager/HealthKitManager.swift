// HealthKit.swift
// LogFlex
//
// Created by Avery Roth on 10/3/24.
//

import Foundation
import HealthKit

// MARK: - Date Extension
extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Double Extension
extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

// MARK: - HealthKitManager
@MainActor
class HealthKitManager: ObservableObject {
    // MARK: - Properties
    let healthStore = HKHealthStore()

    // Published properties
    @Published var stepCount: Int = 0
    @Published var progress: Double = 0.0
    @Published var caloriesBurned: Double = 0.0
    @Published var caloriesProgress: Double = 0.0
    @Published var milesWalked: Double = 0.0
    @Published var milesProgress: Double = 0.0
    @Published var heartRate: Double = 0.0
    @Published var activeWorkoutDistance: Double = 0
    @Published var isTrackingWorkout = false
    @Published var standHours: Int = 0

    // Workout properties
    private var workoutSession: HKWorkoutSession?
    private var distanceQuery: HKQuery?

    // MARK: - Initialization
    init() {
        requestAuthorization()
    }

    // MARK: - Authorization
    private func requestAuthorization() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let miles = HKQuantityType(.distanceWalkingRunning)
        let heartRate = HKQuantityType(.heartRate)
        let standHours = HKQuantityType.categoryType(forIdentifier: .appleStandHour)!
        let healthTypes: Set = [steps, calories, miles, heartRate, standHours]

        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                await fetchTodaySteps()
                await fetchTodayCalories()
                await fetchMiles()
                await fetchHeartRate()
                await fetchStandHours()
            } catch {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Basic Metrics Fetching
extension HealthKitManager {
    func fetchTodaySteps() async {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { _, result, error in
                // Get the results on the background thread
                let stepCount: Int
                let progress: Double

                if let quantity = result?.sumQuantity(), error == nil {
                    stepCount = Int(quantity.doubleValue(for: .count()))
                    // Calculate progress based on current goal, but don't update properties yet
                    let currentGoal = UserDefaults.standard.integer(forKey: "DailyStepGoal")
                    let goalSteps = currentGoal == 0 ? 10000 : currentGoal
                    progress = min(Double(stepCount) / Double(goalSteps), 1.0)
                    print("Steps: \(stepCount)")
                } else {
                    print("Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                    stepCount = 0
                    progress = 0.0
                }
                
                DispatchQueue.main.async {
                    self.stepCount = stepCount
                    self.progress = progress
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchTodayCalories() async {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: calories,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Get the results on the background thread
                let caloriesBurned: Double
                let caloriesProgress: Double

                if let sum = result?.sumQuantity(), error == nil {
                    let calorieUnit = HKUnit.kilocalorie()
                    caloriesBurned = sum.doubleValue(for: calorieUnit)

                    // Calculate progress based on current goal, but don't update properties yet
                    let savedGoal = UserDefaults.standard.double(forKey: "DailyCalorieGoal")
                    let goalCalories = savedGoal == 0 ? 500 : savedGoal
                    caloriesProgress = caloriesBurned / goalCalories
                    print("Total Calories Burned Today: \(caloriesBurned)")
                } else {
                    print("Error fetching calories: \(error?.localizedDescription ?? "Unknown error")")
                    caloriesBurned = 0
                    caloriesProgress = 0
                }

                // Update published properties on main thread and resume continuation
                DispatchQueue.main.async {
                    self.caloriesBurned = caloriesBurned
                    self.caloriesProgress = caloriesProgress
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchHeartRate() async {
        let heartRate = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            end: Date()
        )
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: heartRate,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                // Process on background thread
                let heartRateValue: Double

                if let sample = samples?.first as? HKQuantitySample, error == nil {
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    heartRateValue = sample.quantity.doubleValue(for: heartRateUnit)
                    print("Heart Rate: \(heartRateValue) bpm")
                } else {
                    print("Error fetching heart rate: \(error?.localizedDescription ?? "Unknown error")")
                    heartRateValue = 0
                }

                // Update on main thread
                DispatchQueue.main.async {
                    self.heartRate = heartRateValue
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchMiles() async {
        let miles = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: miles,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                // Process on background thread
                let milesWalked: Double
                let milesProgress: Double

                if let sum = result?.sumQuantity(), error == nil {
                    let mileUnit = HKUnit.mile()
                    milesWalked = sum.doubleValue(for: mileUnit)

                    // Calculate progress based on current goal, but don't update properties yet
                    let savedGoal = UserDefaults.standard.double(forKey: "DailyMileGoal")
                    let goalMiles = savedGoal == 0 ? 10 : savedGoal
                    milesProgress = min(milesWalked / goalMiles, 1.0)
                    print("Miles: \(milesWalked)")
                } else {
                    print("Error fetching miles: \(error?.localizedDescription ?? "Unknown error")")
                    milesWalked = 0
                    milesProgress = 0
                }

                // Update on main thread
                DispatchQueue.main.async {
                    self.milesWalked = milesWalked
                    self.milesProgress = milesProgress
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }

    func fetchStandHours() async {
        let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: standType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                // Process on background thread
                let standHourCount: Int

                if let samples = samples as? [HKCategorySample], error == nil {
                    let calendar = Calendar.current
                    var standHourSet = Set<Int>()

                    for sample in samples {
                        if sample.value == HKCategoryValueAppleStandHour.stood.rawValue {
                            let hour = calendar.component(.hour, from: sample.startDate)
                            standHourSet.insert(hour)
                        }
                    }

                    standHourCount = standHourSet.count
                    print("Stand Hours: \(standHourCount)")
                } else {
                    print("Error fetching stand hours: \(error?.localizedDescription ?? "Unknown error")")
                    standHourCount = 0
                }

                // Update on main thread
                DispatchQueue.main.async {
                    self.standHours = standHourCount
                    continuation.resume()
                }
            }

            healthStore.execute(query)
        }
    }
}

// MARK: - Historical Data Fetching
extension HealthKitManager {
    func fetchSteps(for date: Date, completion: @escaping (Int) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: HKQuantityType(.stepCount),
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result,
                  let sum = result.sumQuantity() else {
                completion(0)
                return
            }

            let steps = Int(sum.doubleValue(for: .count()))
            completion(steps)
        }

        healthStore.execute(query)
    }

    func fetchCalories(for date: Date, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: HKQuantityType(.activeEnergyBurned),
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            guard let result = result,
                  let sum = result.sumQuantity() else {
                completion(0)
                return
            }

            let calories = sum.doubleValue(for: .kilocalorie())
            completion(calories)
        }

        healthStore.execute(query)
    }

    func fetchWorkoutHeartRate(start: Date, end: Date, completion: @escaping (Int?) -> Void) {
        let heartRate = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(
            sampleType: heartRate,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            DispatchQueue.main.async {
                guard let samples = samples as? [HKQuantitySample], error == nil else {
                    print("Error fetching heart rate: \(error?.localizedDescription ?? "Unknown error")")
                    completion(nil)
                    return
                }

                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let heartRates = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }

                if !heartRates.isEmpty {
                    let averageHeartRate = Int(heartRates.reduce(0, +) / Double(heartRates.count))
                    completion(averageHeartRate)
                } else {
                    completion(nil)
                }
            }
        }
        healthStore.execute(query)
    }
}

// MARK: - Workout Tracking
extension HealthKitManager {
    func startWorkoutTracking(for type: HKWorkoutActivityType) {
        guard let distanceType = distanceTypeFor(workoutType: type) else { return }

        let query = HKAnchoredObjectQuery(
            type: distanceType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            Task {
                await self?.handleDistanceUpdate(samples)
            }
        }

        query.updateHandler = { [weak self] query, samples, deleted, anchor, error in
            Task {
                await self?.handleDistanceUpdate(samples)
            }
        }

        distanceQuery = query
        healthStore.execute(query)
        isTrackingWorkout = true
    }

    func stopWorkoutTracking() {
        if let query = distanceQuery {
            healthStore.stop(query)
        }
        isTrackingWorkout = false
        activeWorkoutDistance = 0
        distanceQuery = nil
    }

    private func handleDistanceUpdate(_ samples: [HKSample]?) async {
        guard let distanceSamples = samples as? [HKQuantitySample] else { return }

        let totalDistance = distanceSamples.reduce(0.0) { result, sample in
            result + sample.quantity.doubleValue(for: .meter())
        }

        await MainActor.run {
            self.activeWorkoutDistance = totalDistance / 1609.34
        }
    }
    private func distanceTypeFor(workoutType: HKWorkoutActivityType) -> HKQuantityType? {
        switch workoutType {
        case .running, .walking:
            return HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .cycling:
            return HKQuantityType.quantityType(forIdentifier: .distanceCycling)
        case .swimming:
            return HKQuantityType.quantityType(forIdentifier: .distanceSwimming)
        default:
            return nil
        }
    }
}

// MARK: - Goals Management
extension HealthKitManager {
    // Step Goals
    var currentStepGoal: Int {
        get {
            UserDefaults.standard.integer(forKey: "DailyStepGoal") == 0 ? 10000 : UserDefaults.standard.integer(forKey: "DailyStepGoal")
        }
    }

    func updateStepGoal(_ newGoal: Int) {
        UserDefaults.standard.set(newGoal, forKey: "DailyStepGoal")
        self.progress = Double(self.stepCount) / Double(newGoal)
        objectWillChange.send()
    }

    // Calorie Goals
    var goalCalories: Double {
        get {
            let savedGoal = UserDefaults.standard.double(forKey: "DailyCalorieGoal")
            return savedGoal == 0 ? 500 : savedGoal
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "DailyCalorieGoal")
        }
    }

    func updateCalorieGoal(_ newGoal: Double) {
        UserDefaults.standard.set(newGoal, forKey: "DailyCalorieGoal")
        self.caloriesProgress = self.caloriesBurned / newGoal
        objectWillChange.send()
    }

    // Mile Goals
    var goalMiles: Double {
        get {
            let savedGoal = UserDefaults.standard.double(forKey: "DailyMileGoal")
            return savedGoal == 0 ? 10 : savedGoal
        }
    }

    func updateMileGoal(_ newGoal: Double) {
        UserDefaults.standard.set(newGoal, forKey: "DailyMileGoal")
        self.milesProgress = min(self.milesWalked / newGoal, 1.0)
        objectWillChange.send()
    }
}
