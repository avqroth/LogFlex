import SwiftUI
import SwiftData
import Charts

struct AppleStyleHeartRateView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeRange = TimeRange.week
    @State private var heartRateData: [HeartRatePoint] = []
    @State private var avgHeartRate: Double = 61

    // Time range selection options
    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "D"
        case week = "W"
        case month = "M"

        var id: String { self.rawValue }
    }

    struct HeartRatePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let label: String
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navigation bar
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Summary")
                        }
                        .foregroundColor(.blue)
                    }

                    Spacer()

                    Text("Resting Heart Rate")
                        .fontWeight(.semibold)

                    Spacer()
                }
                .padding()

                Divider()

                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Time range selector
                        HStack(spacing: 0) {
                            ForEach(TimeRange.allCases) { range in
                                Button(action: { selectedTimeRange = range }) {
                                    Text(range.rawValue)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            selectedTimeRange == range ?
                                            Color.gray.opacity(0.6) :
                                            Color.gray.opacity(0.2)
                                        )
                                }
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                        .padding(.top)

                        // Average display
                        VStack(alignment: .leading) {
                            Text("AVERAGE")
                                .font(.caption)
                                .foregroundColor(.gray)

                            HStack(alignment: .firstTextBaseline) {
                                Text("\(Int(avgHeartRate))")
                                    .font(.system(size: 80, weight: .thin))

                                Text("BPM")
                                    .foregroundColor(.gray)
                            }

                            Text(getDateRangeText())
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                        // Heart rate chart
                        heartRateChart()
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                }
            }
            .background(Color.black)
            .foregroundColor(.white)
            .onAppear { generateHeartRateData() }
            .onChange(of: selectedTimeRange) { generateHeartRateData() }
            .navigationBarHidden(true)
        }
    }

    private func heartRateChart() -> some View {
        VStack {
            // Chart
            GeometryReader { geometry in
                let chartWidth = geometry.size.width - 30
                let chartHeight = geometry.size.height - 20

                ZStack {
                    // Grid lines
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach([200, 190, 180, 170, 160, 150, 140, 130, 100, 90, 80, 70, 60, 50], id: \.self) { value in
                            HStack {
                                Text("\(value)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 25, alignment: .trailing)

                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }

                    // Line chart
                    if heartRateData.count > 1 {
                        Path { path in
                            let minValue = 50.0
                            let maxValue = 80.0
                            let valueRange = maxValue - minValue
                            let xStep = chartWidth / CGFloat(heartRateData.count - 1)

                            for (index, point) in heartRateData.enumerated() {
                                let x = 30 + CGFloat(index) * xStep
                                let y = chartHeight - chartHeight * CGFloat((point.value - minValue) / valueRange)

                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(Color.red, lineWidth: 2)

                        // Data points
                        ForEach(heartRateData.indices, id: \.self) { index in
                            let point = heartRateData[index]
                            let minValue = 50.0
                            let maxValue = 80.0
                            let valueRange = maxValue - minValue
                            let xStep = chartWidth / CGFloat(heartRateData.count - 1)

                            let x = 30 + CGFloat(index) * xStep
                            let y = chartHeight - chartHeight * CGFloat((point.value - minValue) / valueRange)

                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                                .position(x: x, y: y)
                        }
                    }
                }
            }

            // X-axis labels
            HStack(spacing: 0) {
                // Space to align with chart
                Text("")
                    .frame(width: 30)

                // Labels
                HStack(spacing: 0) {
                    ForEach(heartRateData.indices, id: \.self) { index in
                        Text(heartRateData[index].label)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8)
        }
    }

    private func getDateRangeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        switch selectedTimeRange {
        case .day:
            return formatter.string(from: Date())
        case .week:
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -6, to: Date())!
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: Date()))"
        case .month:
            let calendar = Calendar.current
            let startDate = calendar.date(byAdding: .day, value: -29, to: Date())!
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: Date()))"
        }
    }

    private func generateHeartRateData() {
        heartRateData = []
        let calendar = Calendar.current

        switch selectedTimeRange {
        case .day:
            // Sample data for hours in a day
            let hoursToLabel = [0, 6, 12, 18]

            for hour in 0..<24 {
                if let date = calendar.date(byAdding: .hour, value: hour, to: calendar.startOfDay(for: Date())) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h a"

                    let label = hoursToLabel.contains(hour) ? formatter.string(from: date) : ""
                    let value = Double.random(in: 55...75)

                    heartRateData.append(HeartRatePoint(date: date, value: value, label: label))
                }
            }

        case .week:
            // Sample data for days in a week
            let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let values = [62, 64, 59, 56, 60, 60, 67]

            for i in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: -6 + i, to: Date()) {
                    heartRateData.append(HeartRatePoint(
                        date: date,
                        value: Double(values[i]),
                        label: weekdays[i]
                    ))
                }
            }

        case .month:
            // Sample data for a month (simplified)
            let labeledDays = [1, 10, 20, 30]

            for day in 1...30 {
                if let date = calendar.date(byAdding: .day, value: -(30-day), to: Date()) {
                    let label = labeledDays.contains(day) ? "\(day)" : ""
                    let value = Double.random(in: 55...75)

                    heartRateData.append(HeartRatePoint(date: date, value: value, label: label))
                }
            }
        }
    }
}

#Preview {
    AppleStyleHeartRateView()
        .preferredColorScheme(.dark)
}
