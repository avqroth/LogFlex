//
//  InfoCard.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.blue.opacity(0.8))
                    .cornerRadius(8)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Text(value.capitalized)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

