//
//  MealSummaryRow.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct MealSummaryRow: View {
    var mealType: String
    var calories: Int
    var items: Int

    var body: some View {
        VStack {
            HStack {
                Text(mealType)
                    .font(.headline)

                Spacer()

                Text("\(calories) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                if items == 0 {
                    Text("No items added")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(items) item\(items == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}


#Preview {
    MealSummaryRow(mealType: "", calories: 0, items: 0)
}
