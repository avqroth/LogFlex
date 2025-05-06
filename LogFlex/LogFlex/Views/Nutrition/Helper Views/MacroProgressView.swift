//
//  MacroProgress.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct MacroProgressView: View {
    var title: String
    var consumed: String
    var goal: String
    var progress: Double
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)

                Spacer()

                Text("\(consumed)g / \(goal)g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressBar(value: progress, color: color)
        }
        .padding(.horizontal)
    }
}
