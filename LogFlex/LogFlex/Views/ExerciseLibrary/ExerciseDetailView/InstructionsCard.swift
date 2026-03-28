//
//  InstructionsCard.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct InstructionsCard: View {
    let instructions: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Instructions")
                    .font(.title3)
                    .fontWeight(.bold)

                Spacer()

                Image(systemName: "text.append")
                    .foregroundColor(.blue)
            }

            Divider()

            Text(instructions)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

