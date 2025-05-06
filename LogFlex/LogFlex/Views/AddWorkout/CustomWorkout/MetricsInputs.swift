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
            // Exercise name header
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .shadow(color: shadowColor, radius: 10, x: 0, y: 2)
        )
        .padding(.horizontal)
    }

    // MARK: - Strength Training Metrics
    private var strengthMetricsView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                metricCardView(
                    value: $setsString,
                    icon: "square.stack.3d.up.fill",
                    label: "Sets",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.sets = String(val) } }
                )

                metricCardView(
                    value: $repsString,
                    icon: "repeat",
                    label: "Reps",
                    keyboardType: .numberPad,
                    onChange: { if let val = Int($0) { metrics.reps = String(val) } }
                )
            }

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
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Cardio Metrics
    private var cardioMetricsView: some View {
        VStack(spacing: 16) {
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
            }

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
            }

            metricCardView(
                value: $durationString,
                icon: "clock",
                label: "Duration",
                subtitle: "(minutes)",
                keyboardType: .numberPad,
                onChange: { if let val = Int($0) { metrics.duration = String(val) } },
                showTrend: true,
                trendValue: compareToExerciseMetric(currentValue: metrics.duration, previousValue: exerciseMetrics.duration, higherIsBetter: false)
            )

            metricCardView(
                value: $caloriesString,
                icon: "flame.fill",
                label: "Calories burned",
                keyboardType: .numberPad,
                onChange: { if let val = Int($0) { metrics.calories = String(val) } },
                showTrend: true,
                trendValue: compareToExerciseMetric(currentValue: metrics.calories, previousValue: exerciseMetrics.calories)
            )
        }
    }

    // MARK: - Metric Card Components
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
        VStack {
            HStack(alignment: .top, spacing: 16) {
                // Icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [accentColor, accentColor.opacity(0.7)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .semibold))
                }

                VStack(alignment: .leading, spacing: 6) {
                    // Label
                    VStack(alignment: .leading, spacing: 2) {
                        Text(label)
                            .font(titleFont)
                            .foregroundColor(.primary)

                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(captionFont)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Text field with animated focus state
                    ZStack(alignment: .leading) {
                        TextField("0", text: value)
                            .keyboardType(keyboardType)
                            .font(valueFont)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(secondaryBackgroundColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isEditing ? accentColor : Color.clear, lineWidth: 2)
                                    )
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isEditing = true
                                }
                            }
                            .onChange(of: value.wrappedValue) {
                                onChange(value.wrappedValue)
                            }
                            .onSubmit {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isEditing = false
                                }
                            }

                        // Show trend indicator if applicable
                        if showTrend, let trend = trendValue, trend != 0 {
                            HStack {
                                Spacer()

                                HStack(spacing: 2) {
                                    Image(systemName: trend > 0 ? "arrow.up" : "arrow.down")
                                    Text("\(abs(trend), specifier: "%.1f")%")
                                        .font(.caption2.bold())
                                }
                                .foregroundColor(trend > 0 ? .green : .red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill((trend > 0 ? Color.green : Color.red).opacity(0.15))
                                )
                            }
                            .padding(.trailing, 12)
                        }
                    }
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 4, x: 0, y: 1)
            )
        }
    }

    // MARK: - Helper Functions

    // Calculate percentage difference between current and previous metrics
    private func compareToExerciseMetric(currentValue: String, previousValue: String, higherIsBetter: Bool = true) -> Double? {
        guard let current = Double(currentValue), let previous = Double(previousValue), previous > 0 else {
            return nil
        }

        let percentChange = ((current - previous) / previous) * 100
        return higherIsBetter ? percentChange : -percentChange
    }
}
