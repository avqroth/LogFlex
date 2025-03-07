//
//  MetricView.swift
//  LogFlex
//
//  Created by Avery Roth on 2/4/25.
//

import SwiftUI

struct MetricView: View {
    let icon: String
    let value: String
    let unit: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .fontWeight(.semibold)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    MetricView(icon: "", value: "", unit: "")
}
