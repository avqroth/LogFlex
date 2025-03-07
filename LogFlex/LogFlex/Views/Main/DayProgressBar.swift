//
//  DayProgressBar.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI

struct DayProgressBar: View {
    let progress: Double
    let value: Int
    let dayIndex: Int

    private var dayLabel: String {
        let calendar = Calendar.current
        let today = Date()
        if let date = calendar.date(byAdding: .day, value: dayIndex - 6, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date).prefix(1).uppercased()
        }
        return ""
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(dayLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.blue)
                            .frame(height: geometry.size.height * min(max(progress, 0), 1)),
                        alignment: .bottom
                    )
            }
        }
        .frame(width: 35, height: 100)
    }
}
