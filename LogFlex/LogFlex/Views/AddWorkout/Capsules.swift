//
//  Capsules.swift
//  LogFlex
//
//  Created by Avery Roth on 10/8/24.
//

import Foundation
import SwiftUI

struct CapsuleData: Identifiable {
    let id = UUID()
    var name: String
}

class CapsuleViewModel: ObservableObject {
    @Published var capsuleData: [CapsuleData]

    init() {
        capsuleData = [
            CapsuleData(name: "Weightlifting"),
            CapsuleData(name: "HIIT"),
            CapsuleData(name: "Running"),
            CapsuleData(name: "Bodybuilding")
        ]
    }
}

struct CapsuleView: View {
    let data: CapsuleData
    let secondaryColor = Color.backup

    var body: some View {
        VStack {
            Capsule()
                .fill(secondaryColor)
                .frame(width: 100, height: 50)
                .overlay(
                    Text(data.name)
                        .font(.caption)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                )
        }
        .frame(width: 120, height: 80)
    }
}
