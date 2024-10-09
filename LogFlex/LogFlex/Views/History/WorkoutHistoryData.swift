//
//  WorkoutHistoryData.swift
//  LogFlex
//
//  Created by Avery Roth on 9/28/24.
//

import Foundation
import SwiftUI

struct MinimalistCalendarView: View {
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(monthYearString(from: currentDate))
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        Text(String(calendar.component(.day, from: date)))
                            .frame(width: 30, height: 30)
                            .background(isToday(date) ? Color.yellow : Color.clear)
                            .cornerRadius(15)
                            .foregroundColor(isToday(date) ? .black : .primary)
                    } else {
                        Text("")
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else { return [] }

        let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)!
        let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)!

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)

        return calendar.generateDates(for: dateInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
            .map { date in
                if date >= monthInterval.start && date < monthInterval.end {
                    return date
                } else {
                    return nil
                }
            }
    }

    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
}

extension Calendar {
    func generateDates(for dateInterval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        enumerateDates(startingAfter: dateInterval.start,
                       matching: components,
                       matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < dateInterval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}
//struct WorkoutDay: Identifiable {
//    let id = UUID()
//    let day: Int
//    let hasWorkout: Bool
//}
//
//struct WorkoutCalendarView: View {
//    let workoutDays: [WorkoutDay]
//    let currentMonth: String
//    let daysInMonth: Int
//    let firstWeekday: Int
//
//    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
//
//    var body: some View {
//        VStack {
//            Text(currentMonth)
//                .font(.title2)
//                .padding(.bottom, 10)
//
//            LazyVGrid(columns: columns, spacing: 15) {
//                ForEach(0..<7, id: \.self) { index in
//                    Text(dayOfWeekAbbreviation(for: index))
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//
//                ForEach(0..<firstWeekday, id: \.self) { _ in
//                    Text("")
//                }
//
//                ForEach(workoutDays) { workoutDay in
//                    ZStack {
//                        Circle()
//                            .fill(workoutDay.hasWorkout ? Color.blue : Color.clear)
//                            .frame(width: 35, height: 35)
//
//                        Text("\(workoutDay.day)")
//                            .foregroundColor(workoutDay.hasWorkout ? .white : .primary)
//                    }
//                }
//            }
//        }
//        .padding()
//        .background(RoundedRectangle(cornerRadius: 15).fill(Color.gray.opacity(0.1)))
//        .padding()
//    }
//
//    private func dayOfWeekAbbreviation(for index: Int) -> String {
//        let abbreviations = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
//        return abbreviations[index]
//    }
//}
