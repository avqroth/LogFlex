//
//  Untitled 2.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct FilterButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

