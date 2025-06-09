

import SwiftUI

struct MetricsInputs: View {
    @Binding var metrics: ActivityMetrics
    let type: ActivityType
    let showStrengthMetrics: Bool
    let exerciseMetrics: ActivityMetrics
    let exerciseName: String

    // Colors
    private let accentColor = Color.main
    private let backgroundColor = Color(.systemBackground)
    private let secondaryBackgroundColor = Color(.secondarySystemBackground)
    private let shadowColor = Color.black.opacity(0.1)

    // Typography
    private let titleFont = Font.headline
    private let valueFont = Font.system(.body, design: .rounded).weight(.medium)
    private let captionFont = Font.caption

    // Metrics state
    @State private var setsString: String
    @State private var repsString: String
    @State private var weightString: String
    @State private var distanceString: String
    @State private var lapsString: String
    @State private var durationString: String
    @State private var caloriesString: String

    // Animation
    @State private var isEditing = false

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
        VStack(spacing: 20) {
            if !exerciseName.isEmpty {
                HStack {
                    Text(exerciseName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(accentColor)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

            if type == .strength && showStrengthMetrics {
                strengthMetricsView
            } else if type != .strength {
                cardioMetricsView
            }
        }
        .padding(.vertical)
    }

    // MARK: - Strength Training Metrics
    private var strengthMetricsView: some View {
        VStack(spacing: 24) {
            // Metrics card
            VStack(spacing: 0) {
                // Sets
                metricCardView(
                    value: $setsString,
                    icon: "square.stack.3d.up.fill",
                    label: "Sets",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.sets = String(val) } }
                )

                Divider()
                    .background(Color(.systemGray5).opacity(0.5))

                // Reps
                metricCardView(
                    value: $repsString,
                    icon: "repeat",
                    label: "Reps",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.reps = String(val) } }
                )

                Divider()
                    .background(Color(.systemGray5).opacity(0.5))

                // Weight
                metricCardView(
                    value: $weightString,
                    icon: "scalemass.fill",
                    label: "Weight (lbs)",
                    keyboardType: .decimalPad,
                    onChange: { if let val = Int($0) { metrics.weight = String(val) } },
                    showTrend: true,
                    trendValue: compareToExerciseMetric(currentValue: metrics.weight, previousValue: exerciseMetrics.weight)
                )
            }
            .background(Color(.systemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)

            // Previous best
            if let prevWeight = Int(exerciseMetrics.weight), prevWeight > 0 {
                HStack {
                    Image(systemName: "trophy")
                        .foregroundColor(.yellow)

                    Text("Previous best: \(prevWeight) lbs")
                        .font(captionFont)
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var cardioMetricsView: some View {
        VStack(spacing: 0) {
            // Distance
            if [.running, .cycling, .rowing].contains(type) {
                metricCardView(
                    value: $distanceString,
                    icon: "figure.walk",
                    label: "Distance (miles)",
                    keyboardType: .decimalPad,
                    onChange: { if let val = Double($0) { metrics.distance = String(val) } },
                    showTrend: true,
                    trendValue: compareToExerciseMetric(currentValue: metrics.distance, previousValue: exerciseMetrics.distance)
                )

                Divider()
                    .background(Color(.systemGray5).opacity(0.5))
            }

            // Laps
            if type == .swimming {
                metricCardView(
                    value: $lapsString,
                    icon: "arrow.triangle.turn.up.right.circle",
                    label: "Laps",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.laps = String(val) } },
                    showTrend: true,
                    trendValue: compareToExerciseMetric(currentValue: metrics.laps, previousValue: exerciseMetrics.laps)
                )

                Divider()
                    .background(Color(.systemGray5).opacity(0.5))
            }

            // Duration
            metricCardView(
                value: $durationString,
                icon: "clock",
                label: "Duration (minutes)",
                keyboardType: .numberPad,
                onChange: { if let val = Int($0) { metrics.duration = String(val) } },
                showTrend: true,
                trendValue: compareToExerciseMetric(currentValue: metrics.duration, previousValue: exerciseMetrics.duration, higherIsBetter: false)
            )

            Divider()
                .background(Color(.systemGray5).opacity(0.5))

            // Calories
            metricCardView(
                value: $caloriesString,
                icon: "flame.fill",
                label: "Calories Burned",
                keyboardType: .numberPad,
                onChange: { if let val = Int($0) { metrics.calories = String(val) } },
                showTrend: true,
                trendValue: compareToExerciseMetric(currentValue: metrics.calories, previousValue: exerciseMetrics.calories)
            )
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func metricCardView(
        value: Binding<String>,
        icon: String,
        label: String,
        subtitle: String? = nil,
        keyboardType: UIKeyboardType,
        onChange: @escaping (String) -> Void,
        showTrend: Bool = false,
        trendValue: Double? = nil
    ) -> some View {
        HStack {
            // Label
            Text(label)
                .foregroundColor(.primary)
                .font(.system(size: 17))

            Spacer()

            // Trend indicator if applicable
            if showTrend, let trend = trendValue {
                HStack(spacing: 2) {
                    Image(systemName: trend >= 0 ? "arrow.up" : "arrow.down")
                        .font(.caption2)
                        .foregroundColor(trend >= 0 ? .green : .red)

                    Text("\(abs(trend), specifier: "%.1f")%")
                        .font(.caption2)
                        .foregroundColor(trend >= 0 ? .green : .red)
                }
                .padding(.trailing, 4)
            }

            // Input field
            TextField("0", text: value)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .font(.system(size: 17))
                .onChange(of: value.wrappedValue) { newValue in
                    onChange(newValue)
                }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }

    private func compareToExerciseMetric(currentValue: String, previousValue: String, higherIsBetter: Bool = true) -> Double? {
        guard let current = Double(currentValue), let previous = Double(previousValue), previous > 0 else {
            return nil
        }

        let percentChange = ((current - previous) / previous) * 100
        return higherIsBetter ? percentChange : -percentChange
    }
}
