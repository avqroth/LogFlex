//
//  MetricsInputs.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import SwiftUI

struct MetricsInputs: View {
    @Binding var metrics: ActivityMetrics
    let type: ActivityType
    let showStrengthMetrics: Bool
    let exerciseMetrics: ActivityMetrics
    let exerciseName: String
    let accentColor = Color.main

    @State private var setsString: String
    @State private var repsString: String
    @State private var weightString: String
    @State private var distanceString: String
    @State private var lapsString: String
    @State private var durationString: String
    @State private var caloriesString: String

    init(metrics: Binding<ActivityMetrics>, type: ActivityType, showStrengthMetrics: Bool, exerciseMetrics: ActivityMetrics, exerciseName: String) {
        self._metrics = metrics
        self.type = type
        self.showStrengthMetrics = showStrengthMetrics
        self.exerciseMetrics = exerciseMetrics
        self.exerciseName = exerciseName

        self._setsString = State(initialValue: "\(metrics.wrappedValue.sets)")
        self._repsString = State(initialValue: "\(metrics.wrappedValue.reps)")
        self._weightString = State(initialValue: "\(metrics.wrappedValue.weight)")
        self._distanceString = State(initialValue: "\(metrics.wrappedValue.distance)")
        self._lapsString = State(initialValue: "\(metrics.wrappedValue.laps)")
        self._durationString = State(initialValue: "\(metrics.wrappedValue.duration)")
        self._caloriesString = State(initialValue: "\(metrics.wrappedValue.calories)")
    }

    var body: some View {
        VStack(spacing: 16) {
            if type == .strength && showStrengthMetrics {
                // Strength training metrics in a grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    // Sets
                    metricField(
                        value: $setsString,
                        icon: "square.stack.3d.up.fill",
                        label: "Sets",
                        keyboardType: .numberPad,
                        onChange: { if let val = Int($0) { metrics.sets = String(val) } }                    )

                    // Reps
                    metricField(
                        value: $repsString,
                        icon: "repeat",
                        label: "Reps",
                        keyboardType: .numberPad,
                        onChange: { if let val = Int($0) { metrics.reps = String(val) } }
                    )

                    // Weight (spans full width)
                    metricField(
                        value: $weightString,
                        icon: "scalemass.fill",
                        label: "Weight (lbs)",
                        keyboardType: .decimalPad,
                        onChange: { if let val = Int($0) { metrics.weight = String(val) } }
                    )
                    .gridCellColumns(2)
                }
            } else if type != .strength {
                if [.running, .cycling].contains(type) {
                    metricField(
                        value: $distanceString,
                        icon: "figure.walk",
                        label: "Distance (miles)",
                        keyboardType: .decimalPad,
                        onChange: { if let val = Double($0) { metrics.distance = String(val) } }
                    )
                }

                if type == .swimming {
                    metricField(
                        value: $lapsString,
                        icon: "arrow.triangle.turn.up.right.circle",
                        label: "Laps",
                        keyboardType: .numberPad,
                        onChange: { if let val = Int($0) { metrics.laps = String(val) } }
                    )
                }

                metricField(
                    value: $durationString,
                    icon: "clock",
                    label: "Duration (minutes)",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.duration = String(val) } }
                )

                metricField(
                    value: $caloriesString,
                    icon: "flame",
                    label: "Calories",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.calories = String(val) } }
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .padding(.horizontal)
    }

    private func metricField(value: Binding<String>, icon: String, label: String, keyboardType: UIKeyboardType, onChange: @escaping (String) -> Void) -> some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .foregroundColor(Color.main)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                // Label
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Text field
                TextField("0", text: value)
                    .keyboardType(keyboardType)
                    .padding(10)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .onChange(of: value.wrappedValue) {
                            onChange(value.wrappedValue)
                        }
            }
        }
    }
}
