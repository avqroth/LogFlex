//
//  Untitled.swift
//  LogFlex
//
//  Created by Avery Roth on 5/6/25.
//
import SwiftUI

struct MonthSelectorView: View {
    @Binding var selectedMonth: Date

    var body: some View {
        HStack {
            Button(action: decrementMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .padding()
            }

            Spacer()

            Text(selectedMonth, format: .dateTime.month().year())
                .font(.headline)

            Spacer()

            Button(action: incrementMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(.blue)
                    .padding()
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func decrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }

    private func incrementMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}
