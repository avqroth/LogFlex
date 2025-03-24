//
//  HealthKit.swift
//  LogFlex
//
//  Created by Avery Roth on 10/3/24.
//

import Foundation
import HealthKit

extension Date {
    static var startOfDay: Date {
        Calendar.current.startOfDay(for: Date())
    }
}

@MainActor
class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
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
    private var workoutSession: HKWorkoutSession?
    private var distanceQuery: HKQuery?
    let goalSteps: Int = 10000
    let goalMiles: Double = 10

    init() {
        requestAuthorization()
    }

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
                fetchTodaySteps()
                fetchTodayCalories()
                fetchMiles()
                fetchHeartRate()
                fetchStandHours()
            } catch {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
            }
        }
    }

    func fetchTodaySteps() {
        let steps = HKQuantityType(.stepCount)
        let predicate = HKQuery.predicateForSamples(withStart: Date.startOfDay, end: Date())

        let query = HKStatisticsQuery(quantityType: steps, quantitySamplePredicate: predicate) { [weak self] _, result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let quantity = result?.sumQuantity(), error == nil else {
                    print("Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.stepCount = Int(quantity.doubleValue(for: .count()))
                self.progress = min(Double(self.stepCount) / Double(self.goalSteps), 1.0)
                print("Steps: \(self.stepCount)")
            }
        }
        healthStore.execute(query)
    }


    func fetchTodayCalories() {
        let calories = HKQuantityType(.activeEnergyBurned)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(
            quantityType: calories,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching calories: \(error.localizedDescription)")
                    return
                }

                guard let sum = result?.sumQuantity() else {
                    print("No calories data available")
                    return
                }

                let calorieUnit = HKUnit.kilocalorie()
                self.caloriesBurned = sum.doubleValue(for: calorieUnit)
                print("Total Calories Burned Today: \(self.caloriesBurned)")
            }
        }

        healthStore.execute(query)
    }



    func fetchMiles() {
        let miles = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: miles, quantitySamplePredicate: predicate, options: .cumulativeSum)
        { [weak self] _, result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    print("Error fetching calories: \(error.localizedDescription)")
                    return
                }
                guard let sum = result?.sumQuantity() else {
                    print("No miles data available")
                    return
                }
                let mileUnit = HKUnit.mile()
                self.milesWalked = sum.doubleValue(for: mileUnit)
                print("Miles: \(self.milesWalked)")
            }
        }
        healthStore.execute(query)
    }


    func fetchHeartRate() {
        let heartRate = HKQuantityType(.heartRate)
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .hour, value: -1, to: Date()), end: Date())
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)

        let query = HKSampleQuery(sampleType: heartRate, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                guard let sample = samples?.first as? HKQuantitySample, error == nil else {
                    print("Error fetching heart rate: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                self?.heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                print("Heart Rate: \(self?.heartRate ?? 0) bpm")
            }
        }
        healthStore.execute(query)
    }

    func startWorkoutTracking(for type: HKWorkoutActivityType) {
        guard let distanceType = distanceTypeFor(workoutType: type) else { return }

        let query = HKAnchoredObjectQuery(
            type: distanceType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.handleDistanceUpdate(samples)
        }

        query.updateHandler = { [weak self] query, samples, deleted, anchor, error in
            self?.handleDistanceUpdate(samples)
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

    private func handleDistanceUpdate(_ samples: [HKSample]?) {
        guard let distanceSamples = samples as? [HKQuantitySample] else { return }

        let totalDistance = distanceSamples.reduce(0.0) { result, sample in
            result + sample.quantity.doubleValue(for: .meter())
        }

        DispatchQueue.main.async {
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

    func fetchStandHours() {
        let standType = HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())

        let query = HKSampleQuery(
            sampleType: standType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil
        ) { [weak self] _, samples, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching stand hours: \(error.localizedDescription)")
                    return
                }

                // Count unique stand hours
                if let samples = samples as? [HKCategorySample] {
                    let calendar = Calendar.current
                    var standHourSet = Set<Int>()

                    for sample in samples {
                        if sample.value == HKCategoryValueAppleStandHour.stood.rawValue {
                            let hour = calendar.component(.hour, from: sample.startDate)
                            standHourSet.insert(hour)
                        }
                    }

                    self.standHours = standHourSet.count
                    print("Stand Hours: \(self.standHours)")
                }
            }
        }

        healthStore.execute(query)
    }
}


extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}

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
}

extension HealthKitManager {
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

extension HealthKitManager {
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
}

extension HealthKitManager {
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
}


