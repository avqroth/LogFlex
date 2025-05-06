//
//  TabButton.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .bold : .regular)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        }
                    }
                )
        }
        .foregroundColor(isSelected ? .blue : .gray)
    }
}

