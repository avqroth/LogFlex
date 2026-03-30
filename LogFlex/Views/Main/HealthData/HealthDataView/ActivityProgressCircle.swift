//
//  ActivityProgressCircle.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct ActivityProgressCircle: View {
    let title: String
    let value: String
    let progress: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(
                        color.opacity(0.2),
                        lineWidth: 10
                    )

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: 10,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut, value: progress)

                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            .frame(width: 100, height: 100)

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .padding(.top)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

