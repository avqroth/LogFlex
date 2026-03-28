//
//  ExerciseTag.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseTag: View {
    let text: String
    let icon: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .foregroundColor(.gray)
    }
}


#Preview {
    ExerciseTag(text: "", icon: "")
}
