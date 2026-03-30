//
//  EmptyDayView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//

import SwiftUI

struct EmptyDayView: View {
    let date: Date

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "fork.knife")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.7))
                .padding(.bottom)

            Text("No nutrition data for \(date, format: .dateTime.month().day().year())")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Add meals to see your nutrition data for this day.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

