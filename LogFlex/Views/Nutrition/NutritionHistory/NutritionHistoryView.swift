//
//  NutritionHistoryView.swift
//  LogFlex
//
//  Created by Avery Roth on 10/3/24.
//

import SwiftUI

struct NutritionHistoryView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @State private var selectedDate: Date = Date()
    @State private var selectedMonth: Date = Date()
    @State private var selectedMetric: NutritionMetric = .calories

    enum NutritionMetric: String, CaseIterable {
        case calories = "Calories"
        case protein = "Protein"
        case carbs = "Carbs"
        case fat = "Fat"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Metric selector
                Picker("Metric", selection: $selectedMetric) {
                    ForEach(NutritionMetric.allCases, id: \.self) { metric in
                        Text(metric.rawValue).tag(metric)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // Month selector
                MonthSelectorView(selectedMonth: $selectedMonth)
                    .padding(.horizontal)

                // Calendar view
                NutritionCalendarView(
                    nutritionManager: nutritionManager,
                    selectedDate: $selectedDate,
                    selectedMonth: $selectedMonth,
                    selectedMetric: selectedMetric
                )
                .padding(.horizontal)

                // Selected day details
                if let dayData = getDayData(for: selectedDate) {
                    SelectedDayNutritionView(
                        nutritionManager: nutritionManager,
                        date: selectedDate,
                        dayData: dayData
                    )
                    .padding(.horizontal)
                } else {
                    EmptyDayView(date: selectedDate)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Nutrition History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getDayData(for date: Date) -> DailyNutritionData? {
        let calendar = Calendar.current
        let dayEntries = nutritionManager.entries.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }

        if dayEntries.isEmpty {
            return nil
        }

        let calories = dayEntries.reduce(0) { $0 + $1.calories }
        let protein = dayEntries.reduce(0.0) { $0 + $1.protein }
        let carbs = dayEntries.reduce(0.0) { $0 + $1.carbs }
        let fat = dayEntries.reduce(0.0) { $0 + $1.fat }

        return DailyNutritionData(
            date: date,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat
        )
    }
}

