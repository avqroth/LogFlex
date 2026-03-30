//
//  MacroTargetRow.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct MacroTargetRow: View {
    var title: String
    var grams: Double
    var percentage: Double
    var color: Color

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text("\(Int(grams))g")
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("(\(Int(percentage))%)")
                .foregroundColor(.secondary)
                .font(.callout)
        }
    }
}
