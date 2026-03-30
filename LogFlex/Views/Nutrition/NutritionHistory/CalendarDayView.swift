//
//  CalendarDayView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let dayData: DailyNutritionData?
    let selectedMetric: NutritionHistoryView.NutritionMetric

    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )

            VStack(spacing: 2) {
                // Day number
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .primary)

                // Nutrition data if available
                if let data = dayData {
                    Text(valueForMetric(data))
                        .font(.system(size: 10))
                        .foregroundColor(colorForMetric)
                        .lineLimit(1)
                }
            }
            .padding(4)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func valueForMetric(_ data: DailyNutritionData) -> String {
        switch selectedMetric {
        case .calories: return "\(data.calories)"
        case .protein: return "\(Int(data.protein))g"
        case .carbs: return "\(Int(data.carbs))g"
        case .fat: return "\(Int(data.fat))g"
        }
    }

    private var colorForMetric: Color {
        switch selectedMetric {
        case .calories: return .orange
        case .protein: return .blue
        case .carbs: return .green
        case .fat: return .yellow
        }
    }
}

