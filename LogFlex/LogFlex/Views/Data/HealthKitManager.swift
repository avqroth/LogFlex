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
    @Published var caloriesBurned: Double = 0
    @Published var caloriesProgress: Double = 0.0
    @Published var milesWalked: Double = 0.0
    @Published var milesProgress: Double = 0.0
    @Published var heartRate: Double = 0.0
    let goalSteps: Int = 10000
    let goalMiles: Double = 10
    let goalCalories: Double = 500
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        let steps = HKQuantityType(.stepCount)
        let calories = HKQuantityType(.activeEnergyBurned)
        let miles = HKQuantityType(.distanceWalkingRunning)
        let heartRate = HKQuantityType(.heartRate)
        let healthTypes: Set = [steps, calories, miles, heartRate]
        
        Task {
            do {
                try await healthStore.requestAuthorization(toShare: [], read: healthTypes)
                fetchTodaySteps()
                fetchTodayCalories()
                fetchMiles()
                fetchHeartRate()
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
        
        let query = HKStatisticsQuery(quantityType: calories, quantitySamplePredicate: predicate) { [weak self] _, result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let quantity = result?.sumQuantity(), error == nil else {
                    print("Error fetching calories: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.caloriesBurned = quantity.doubleValue(for: .kilocalorie())
                self.caloriesProgress = min(self.caloriesBurned / self.goalMiles, 1.0)
                print("Calories: \(self.caloriesBurned.formattedString())")
            }
        }
        healthStore.execute(query)
    }
    
    func fetchMiles() {
        let miles = HKQuantityType(.distanceWalkingRunning)
        let predicate = HKQuery.predicateForSamples(withStart: .startOfDay, end: Date())
        let query = HKStatisticsQuery(quantityType: miles, quantitySamplePredicate: predicate) { [weak self] _, result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                guard let quantity = result?.sumQuantity(), error == nil else {
                    print("Error fetching miles: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.milesWalked = quantity.doubleValue(for: .mile())
                self.milesProgress = min(self.caloriesBurned / self.goalMiles, 1.0)
                print("Miles: \(self.milesWalked.formattedString())")
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
}

extension Double {
    func formattedString() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
