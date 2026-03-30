//
//  NutritionCalendarView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI


struct NutritionCalendarView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @Binding var selectedDate: Date
    @Binding var selectedMonth: Date
    let selectedMetric: NutritionHistoryView.NutritionMetric

    private let daysOfWeek = ["S", "M", "T", "W", "T", "F", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // Days of week header
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(days, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                            dayData: getDayData(for: date),
                            selectedMetric: selectedMetric
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedDate = date
                            }
                        }
                    } else {
                        // Empty cell for days not in the month
                        Color.clear
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }

    // Get all days in the current month view
    private var days: [Date?] {
        let calendar = Calendar.current

        // Get start of the month
        let monthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: selectedMonth)
        )!

        // Get range of days in month
        let range = calendar.range(of: .day, in: .month, for: monthStart)!

        // Get weekday of the first day (0 = Sunday)
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1

        // Create array of dates
        var days = [Date?](repeating: nil, count: firstWeekday)

        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        // Add padding to ensure complete weeks
        let remainder = (days.count % 7)
        if remainder > 0 {
            days.append(contentsOf: [Date?](repeating: nil, count: 7 - remainder))
        }

        return days
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
