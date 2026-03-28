//
//  MacroLegendItem.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI

struct MacroLegendItem: View {
    var color: Color
    var title: String
    var percentage: Double

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)

                Text("\(Int(percentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

