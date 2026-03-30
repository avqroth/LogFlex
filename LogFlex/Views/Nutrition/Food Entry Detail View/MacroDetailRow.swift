//
//  Untitled.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI

struct MacroDetailRow: View {
    var title: String
    var value: String
    var unit: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.primary)

            Spacer()

            Text("\(value) \(unit)")
                .fontWeight(.semibold)
        }
    }
}

