//
//  Untitled.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//
import SwiftUI

struct QuickAddButton: View {
    var title: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(title)
                    .font(.caption)
                    .bold()

                Text("\(calories) cal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
            )
        }
        .foregroundColor(.primary)
    }
}
