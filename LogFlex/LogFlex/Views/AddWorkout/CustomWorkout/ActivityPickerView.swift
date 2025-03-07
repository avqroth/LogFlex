//
//  ActivityPickerView.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import SwiftUI

struct ActivityPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (ActivityType) -> Void

    var body: some View {
        NavigationView {
            List(ActivityType.allCases, id: \.self) { activity in
                Button {
                    onSelect(activity)
                    dismiss()
                } label: {
                    Label(activity.rawValue, systemImage: activity.icon)
                }
                .foregroundStyle(Color.main)
            }
            .navigationTitle("Choose Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
    }
}

