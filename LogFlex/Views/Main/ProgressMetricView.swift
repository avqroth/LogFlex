//
//  ProgressMetricView.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI

struct ProgressMetricView: View {
    let icon: String
    let value: Int
    let goal: Int
    let color: Color

    var progress: Double {
        Double(value) / Double(goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(value)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("/ \(goal)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
