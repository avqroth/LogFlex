//
//  HealthProgressCircle.swift
//  LogFlex
//
//  Created by Avery Roth on 10/3/24.
//

import SwiftUI

struct Activity {
    let id: Int
    let title: String
    let subtitle: String
    let image: String
    let amount: String
}

struct HealthProgressCircle: View {
    @ObservedObject var healthKitManager: HealthKitManager
    let mainColor = Color.main
    let secondaryColor = Color.backup

    private let gradient = AngularGradient(
        gradient: Gradient(colors: [.main, .backup]),
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 250)
                .padding()

            Circle()
                .trim(from: 0.0, to: CGFloat(min(healthKitManager.progress, 1.0)))
                .stroke(gradient, style: StrokeStyle(lineWidth: 25, lineCap: .round))
                .frame(width: 250)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: healthKitManager.progress)
                .padding()

            VStack {
                Image(systemName: "figure.walk")
                    .foregroundColor(secondaryColor)
                    .font(.system(size: 30))

                Text("\(healthKitManager.stepCount)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                Text("Today")
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .onAppear {
            healthKitManager.fetchTodaySteps()
        }
    }
}
