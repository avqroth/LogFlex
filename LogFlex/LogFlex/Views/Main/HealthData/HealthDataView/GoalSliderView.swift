//
//  GoalSliderView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI

struct GoalSliderView: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let presets: [Double]
    let formatter: (Double) -> String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Current Goal: \(formatter(value))")
                    .font(.headline)
                    .padding(.top)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Presets:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(presets, id: \.self) { preset in
                                Button(action: {
                                    value = preset
                                }) {
                                    Text(formatter(preset))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(value == preset ? Color.blue : Color.gray.opacity(0.2))
                                        )
                                        .foregroundColor(value == preset ? .white : .primary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Custom:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    VStack {
                        Slider(
                            value: $value,
                            in: range,
                            step: step
                        )

                        HStack {
                            Text(formatter(range.lowerBound))
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            Text(formatter(range.upperBound))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                    }
                }
            }
            .padding()
        }
    }
}

