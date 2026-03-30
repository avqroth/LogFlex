//
//  BackButton.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct BackButton: View {
    var dismiss: DismissAction

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            ZStack {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
            }
        }
    }
}

