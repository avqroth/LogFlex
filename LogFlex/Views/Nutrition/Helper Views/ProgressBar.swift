//
//  ProgressBar.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct ProgressBar: View {
    var value: Double
    var color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 12)
                    .opacity(0.1)
                    .foregroundColor(color)
                    .cornerRadius(6)

                Rectangle()
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width), height: 12)
                    .foregroundColor(color)
                    .cornerRadius(6)
                    .animation(.linear, value: value)
            }
        }
        .frame(height: 12)
    }
}
