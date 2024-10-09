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

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var stepCount: Int = 0
    @Published var progress: Double = 0.0
    let goalSteps: Int = 10000
    
    @Published var caloriesBurned: Double = 0
    @Published var progress: Double = 0
    let goalCalories: Double = 500
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            if success {
                self.fetchTodaySteps()
            } else if let error = error {
                print("Authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchTodaySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch steps: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
                self.progress = Double(self.stepCount) / Double(self.goalSteps)
            }
        }
        healthStore.execute(query)
    }
    
    func fetchTodayCalories() {
        guard let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Active Energy Burned type is no longer available in HealthKit")
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch calories: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
                self.progress = min(self.caloriesBurned / self.goalCalories, 1.0)
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
