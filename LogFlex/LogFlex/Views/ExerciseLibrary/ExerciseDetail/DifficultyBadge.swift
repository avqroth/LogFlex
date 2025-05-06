//
//  DifficultyBadge.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct DifficultyBadge: View {
    let level: String

    var difficultyColor: Color {
        switch level.lowercased() {
        case "beginner": return .green
        case "intermediate": return .orange
        case "expert": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(level.capitalized)
            .font(.system(size: 14, weight: .bold))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(difficultyColor.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: difficultyColor.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}


#Preview {
    DifficultyBadge(level: "")
}
