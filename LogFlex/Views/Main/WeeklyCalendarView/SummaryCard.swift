//
//  SummaryCard.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct SummaryCard: View {
    let title: String
    let icon: String
    let color: Color
    let average: Int
    let goal: Int
    let completion: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            Text("Avg: \(average)")
                .font(.title3)
                .fontWeight(.bold)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .cornerRadius(4)

                    Rectangle()
                        .fill(color)
                        .frame(width: min(CGFloat(completion) * geometry.size.width, geometry.size.width))
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

