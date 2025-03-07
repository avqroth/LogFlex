//
//  HeartRateHistoryCard.swift
//  LogFlex
//
//  Created by Avery Roth on 2/13/25.
//

import SwiftUI
import SwiftData
import Charts

struct WorkoutHeartRateGraph: View {
    @Query(sort: \WorkoutLog.date, order: .reverse) private var workouts: [WorkoutLog]

    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()

        // Get current week's Sunday
        guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return []
        }

        // Create array of all days in the week
        return (0...6).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: sunday)
        }
    }

    private var workoutHeartRates: [(Date, Int?, Int?)] {
        let calendar = Calendar.current

        return weekDates.map { date in
            let dayWorkouts = workouts.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }

            let heartRates = dayWorkouts.compactMap { $0.averageHeartRate }
            let minRate = heartRates.min()
            let maxRate = heartRates.max()

            return (date, minRate, maxRate)
        }
    }

    private var heartRateRange: String {
        let rates = workoutHeartRates.compactMap { $0.1 } + workoutHeartRates.compactMap { $0.2 }
        guard !rates.isEmpty else { return "-- BPM" }
        return "\(rates.min() ?? 0)-\(rates.max() ?? 0) BPM"
    }

    private var dateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        guard let firstDate = weekDates.first,
              let lastDate = weekDates.last else {
            return ""
        }

        return "\(formatter.string(from: firstDate))–\(formatter.string(from: lastDate)), \(Calendar.current.component(.year, from: Date()))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("RANGE")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                Text(heartRateRange)
                    .font(.system(size: 32, weight: .semibold))

                Text(dateRange)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Chart {
                // Add marks for all days to ensure proper spacing
                ForEach(weekDates, id: \.self) { date in
                    RectangleMark(
                        x: .value("Day", date, unit: .day),
                        y: .value("BPM", 0),
                        width: 6, height: 0
                    )
                    .foregroundStyle(.clear)
                }

                // Add heart rate data
                ForEach(workoutHeartRates, id: \.0) { date, minHR, maxHR in
                    if let min = minHR, let max = maxHR {
                        RectangleMark(
                            x: .value("Day", date, unit: .day),
                            yStart: .value("Min BPM", min),
                            yEnd: .value("Max BPM", max),
                            width: 6
                        )
                        .foregroundStyle(Color.red)
                    }
                }
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(preset: .aligned, values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            Text(formatDay(date))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.3))
                    if let heartRate = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(heartRate))")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .chartYScale(domain: 40...200)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .gray.opacity(0.2), radius: 10, x: 0, y: 5)
    }

    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

