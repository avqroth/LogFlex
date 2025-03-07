//
//  DifficultyBadge.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct DifficultyBadge: View {
    let level: String

    var color: Color {
        switch level.lowercased() {
        case "beginner": return .green
        case "intermediate": return .orange
        case "expert": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(level.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
    }
}


#Preview {
    DifficultyBadge(level: "")
}
