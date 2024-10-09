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
}

class CircleViewModel: ObservableObject {
    @Published var circleData: [CircleData]

    init() {
        circleData = [
            CircleData(name: "cals", systemName: "heart.fill"),
            CircleData(name: "mi", systemName: "figure.walk.motion"),
            CircleData(name: "hr", systemName: "waveform.path.ecg")
        ]
    }
}

struct CircleView: View {
    let data: CircleData
    let secondaryColor = Color.backup

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(secondaryColor, lineWidth: 5)
                    .frame(width: 75, height: 75)

                Image(systemName: data.systemName)
                    .foregroundColor(.gray)
                    .font(.system(size: 25))
            }

            Text(data.name)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(width: 100, height: 100)
    }
}


#Preview {
    CircleView(data: CircleData(name: "", systemName: ""))
}
