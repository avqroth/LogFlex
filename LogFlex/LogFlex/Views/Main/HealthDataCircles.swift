//
//  HealthDataCircles.swift
//  LogFlex
//
//  Created by Avery Roth on 10/8/24.
//

import SwiftUI

struct CircleData: Identifiable {
    let id = UUID()
    var name: String
    var systemName: String
    var value: String
}

class CircleViewModel: ObservableObject {
    @Published var circleData: [CircleData]

    init() {
        circleData = [
            CircleData(name: "cals", systemName: "flame.fill", value: "0"),
            CircleData(name: "mi", systemName: "figure.walk.motion", value: "0.0"),
            CircleData(name: "bpm", systemName: "waveform.path.ecg", value: "0")
        ]
    }

    func updateCalories(_ calories: Double) {
        if let index = circleData.firstIndex(where: { $0.name == "cals" }) {
            circleData[index].value = String(format: "%.0f", calories)
        }
    }

    func updateMiles(_ miles: Double) {
        if let index = circleData.firstIndex(where: { $0.name == "mi" }) {
            circleData[index].value = String(format: "%.0f", miles)
        }
    }

    func updateHeartRate(_ heartRate: Double) {
        if let index = circleData.firstIndex(where: { $0.name == "bpm" }) {
            circleData[index].value = String(format: "%.0f", heartRate)
        }
    }

}

struct CircleView: View {
    let data: CircleData
    let secondaryColor = Color.backup

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.backup, lineWidth: 5)
                    .frame(width: 75, height: 75)

                Image(systemName: data.systemName)
                    .foregroundColor(.accent)
                    .font(.system(size: 25))
            }

            Text(data.value)
                .font(.headline)
                .foregroundColor(.primary)

            Text(data.name)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 120)
    }
}


#Preview {
    CircleView(data: CircleData(name: "", systemName: "", value: ""))
        .environmentObject(HealthKitManager())
}
