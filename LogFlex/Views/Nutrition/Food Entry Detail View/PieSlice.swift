//
//  PieSlice.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI

struct PieSlice: View {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 100, y: 100))
            path.addArc(
                center: CGPoint(x: 100, y: 100),
                radius: 100,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            path.closeSubpath()
        }
        .fill(color)
        .frame(width: 200, height: 200)
    }
}

