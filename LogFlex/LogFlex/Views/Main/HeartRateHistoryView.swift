import SwiftUI
import SwiftData
import Charts

struct AppleStyleHeartRateView: View {
    let healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeRange = TimeRange.week
    @State private var heartRateData: [HeartRatePoint] = []
    @State private var maxHeartRate: Double = 80
    @State private var minHeartRate: Double = 50
    @State private var avgHeartRate: Double = 61

    // Time range selection options
    enum TimeRange: String, CaseIterable, Identifiable {
        case day = "D"
        case week = "W"
        case month = "M"
        case sixMonth = "6M"
        case year = "Y"

        var id: String { self.rawValue }
    }

    struct HeartRatePoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let label: String
    }

    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"

        let startDate: Date
        let endDate = Date()

        let calendar = Calendar.current
        switch selectedTimeRange {
        case .day:
            return formatter.string(from: endDate)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate)), \(calendar.component(.year, from: endDate))"
        case .month:
            startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate)), \(calendar.component(.year, from: endDate))"
        case .sixMonth:
            startDate = calendar.date(byAdding: .month, value: -6, to: endDate)!
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate)), \(calendar.component(.year, from: endDate))"
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: endDate)!
            formatter.dateFormat = "MMM yyyy"
            return "\(formatter.string(from: startDate)) – \(formatter.string(from: endDate))"
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Navigation bar - custom to match Apple style
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: "chevron.left")
                            Text("Summary")
                        }
                        .foregroundColor(.blue)
                        .font(.system(size: 17))
                    }

                    Spacer()

                    Text("Resting Heart Rate")
                        .font(.system(size: 17, weight: .semibold))

                    Spacer()

                    Text("") // Empty space to balance the back button
                        .frame(width: 80)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)

                Color.gray.opacity(0.3)
                    .frame(height: 0.5)

                // Main content
                ScrollView {
                    VStack(spacing: 20) {
                        // Time range selector
                        segmentedTimeRangePicker()
                            .padding(.horizontal)
                            .padding(.top, 16)

                        // Average display
                        VStack(alignment: .leading, spacing: 4) {
                            Text("AVERAGE")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .padding(.leading)

                            HStack(alignment: .firstTextBaseline, spacing: 5) {
                                Text("\(Int(avgHeartRate))")
                                    .font(.system(size: 80, weight: .thin))

                                Text("BPM")
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                                    .padding(.leading, 4)
                            }
                            .padding(.leading)

                            Text(dateRangeText)
                                .font(.system(size: 17))
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // Heart rate chart
                        heartRateChart()
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                }
                .background(Color.black)
            }
            .navigationBarHidden(true)
            .background(Color.black)
            .foregroundColor(.white)
            .onAppear {
                generateHeartRateData()
            }
            .onChange(of: selectedTimeRange) { _, _ in
                generateHeartRateData()
            }
        }
    }

    private func segmentedTimeRangePicker() -> some View {
        HStack(spacing: 0) {
            ForEach(TimeRange.allCases) { range in
                Button(action: {
                    selectedTimeRange = range
                }) {
                    Text(range.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTimeRange == range ?
                                Color.gray.opacity(0.6) :
                                Color.gray.opacity(0.2)
                        )
                        .foregroundColor(.white)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func heartRateChart() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Y-axis labels (80, 70, 60, 50)
            ZStack {
                // Grid lines
                VStack(alignment: .leading, spacing: 0) {
                    ForEach([80, 70, 60, 50], id: \.self) { value in
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

                // Actual chart
                GeometryReader { geometry in
                    Path { path in
                        guard heartRateData.count > 1 else { return }

                        let width = geometry.size.width - 30 // Account for y-axis labels
                        let height = geometry.size.height

                        let yRange = maxHeartRate - minHeartRate
                        let xStep = width / CGFloat(heartRateData.count - 1)

                        var startPoint = true

                        for (index, point) in heartRateData.enumerated() {
                            let x = 30 + CGFloat(index) * xStep
                            let y = height - height * CGFloat((point.value - minHeartRate) / yRange)

                            if startPoint {
                                path.move(to: CGPoint(x: x, y: y))
                                startPoint = false
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.red, lineWidth: 2)

                    // Data points with improved spacing
                    ForEach(heartRateData.indices, id: \.self) { index in
                        let point = heartRateData[index]
                        let width = geometry.size.width - 30
                        let height = geometry.size.height

                        let yRange = maxHeartRate - minHeartRate
                        let xStep = width / CGFloat(heartRateData.count - 1)

                        let x = 30 + CGFloat(index) * xStep
                        let y = height - height * CGFloat((point.value - minHeartRate) / yRange)

                        ZStack {
                            // Outer circle (white border for emphasis)
                            Circle()
                                .stroke(Color.white, lineWidth: 1)
                                .frame(width: 10, height: 10)

                            // Inner circle (red dot)
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                        }
                        .position(x: x, y: y)
                    }
                }
            }

            // X-axis labels with improved spacing for all time ranges
            HStack(spacing: 0) {
                // Extra space to align with chart
                Text("")
                    .frame(width: 30)

                // Scrollable container for labels when there are many (month/6m/year)
                Group {
                    if selectedTimeRange == .month || selectedTimeRange == .sixMonth || selectedTimeRange == .year {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(heartRateData.indices, id: \.self) { index in
                                    Text(heartRateData[index].label)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .frame(width: getXAxisLabelWidth())
                                        .padding(.horizontal, 4)
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    } else {
                        // Day and Week views (fixed layout)
                        HStack(spacing: 0) {
                            ForEach(heartRateData.indices, id: \.self) { index in
                                Text(heartRateData[index].label)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
    }

    // Helper to determine appropriate label width based on time range
    private func getXAxisLabelWidth() -> CGFloat {
        switch selectedTimeRange {
        case .day:
            return 40
        case .week:
            return 40
        case .month:
            return 25
        case .sixMonth:
            return 40
        case .year:
            return 35
        }
    }

    private func generateHeartRateData() {
        var newData: [HeartRatePoint] = []
        let calendar = Calendar.current
        let now = Date()

        // Default values
        minHeartRate = 50
        maxHeartRate = 80

        switch selectedTimeRange {
        case .day:
            // Full 24 hours from 12am to 12am
            // Get start of today (12am)
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current

            let startOfToday = calendar.startOfDay(for: now)

            // Hours to display labels (12am, 4am, 8am, 12pm, 4pm, 8pm)
            let hoursToLabel = [0, 4, 8, 12, 16, 20]

            // Create data points for each hour of the day
            for hour in 0..<24 {
                if let date = calendar.date(byAdding: .hour, value: hour, to: startOfToday) {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "h a"
                    formatter.amSymbol = "AM"
                    formatter.pmSymbol = "PM"

                    // Only add labels for specific hours to avoid crowding
                    let label = hoursToLabel.contains(hour) ? formatter.string(from: date) : ""

                    // Value simulation for realistic heart rate pattern through the day
                    // Lower at night, higher during day
                    var value: Double
                    if hour < 6 {
                        // Sleeping hours (midnight to 6am)
                        value = Double.random(in: 55...65)
                    } else if hour < 10 {
                        // Morning activity (6am to 10am)
                        value = Double.random(in: 65...75)
                    } else if hour < 18 {
                        // Daytime (10am to 6pm)
                        value = Double.random(in: 62...72)
                    } else if hour < 22 {
                        // Evening (6pm to 10pm)
                        value = Double.random(in: 60...70)
                    } else {
                        // Late night (10pm to midnight)
                        value = Double.random(in: 58...68)
                    }

                    newData.append(HeartRatePoint(date: date, value: value, label: label))
                }
            }

        case .week:
            // 7 days - ordered Sunday through Saturday
            let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

            // Calculate today's weekday (1 = Sunday, 7 = Saturday)
            let todayComponents = calendar.dateComponents([.weekday], from: now)
            let currentWeekday = todayComponents.weekday ?? 1

            // How many days to go back to reach Sunday
            let daysToSunday = currentWeekday - 1

            // Calculate values similar to the reference screenshot but adjusted for Sun-Sat
            let values: [Double] = [62, 64, 59, 56, 60, 60, 67]

            for (index, day) in weekdays.enumerated() {
                if let date = calendar.date(byAdding: .day, value: -daysToSunday + index, to: now) {
                    let value = values[index]
                    newData.append(HeartRatePoint(date: date, value: value, label: day))
                }
            }

            avgHeartRate = 61 // Match screenshot

        case .month:
            // 30 days with labels for selected days only
            let daysInMonth = 30
            let labeledDays = [1, 5, 10, 15, 20, 25, 30] // Only show labels for these days

            for day in 1...daysInMonth {
                if let date = calendar.date(byAdding: .day, value: -(daysInMonth-day), to: now) {
                    // Only add labels for specific days to avoid crowding
                    let label = labeledDays.contains(day) ? "\(day)" : ""
                    let value = Double.random(in: 55...75)
                    newData.append(HeartRatePoint(date: date, value: value, label: label))
                }
            }

        case .sixMonth:
            // 6 months with improved labels
            let monthAbbreviations = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            let currentMonth = calendar.component(.month, from: now) - 1 // 0-based index

            for i in 0..<6 {
                let monthIndex = (currentMonth - i + 12) % 12 // Ensure we wrap around correctly

                // Create a date for this month
                var components = DateComponents()
                components.year = calendar.component(.year, from: now) - (currentMonth - monthIndex < 0 ? 1 : 0)
                components.month = monthIndex + 1
                components.day = 15 // Middle of month

                if let date = calendar.date(from: components) {
                    let label = monthAbbreviations[monthIndex]
                    let value = Double.random(in: 55...75)
                    newData.insert(HeartRatePoint(date: date, value: value, label: label), at: 0)
                }
            }

        case .year:
            // 12 months with all month labels
            let monthAbbreviations = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            let currentMonth = calendar.component(.month, from: now) - 1 // 0-based index

            for i in 0..<12 {
                let monthIndex = (currentMonth - i + 12) % 12 // Ensure we wrap around correctly

                // Create a date for this month
                var components = DateComponents()
                components.year = calendar.component(.year, from: now) - (currentMonth - monthIndex < 0 ? 1 : 0)
                components.month = monthIndex + 1
                components.day = 15 // Middle of month

                if let date = calendar.date(from: components) {
                    let label = monthAbbreviations[monthIndex]
                    let value = Double.random(in: 55...75)
                    newData.insert(HeartRatePoint(date: date, value: value, label: label), at: 0)
                }
            }
        }

        heartRateData = newData
        calculateStats()
    }

    private func calculateStats() {
        if !heartRateData.isEmpty {
            let values = heartRateData.map { $0.value }
            maxHeartRate = values.max() ?? 80
            minHeartRate = values.min() ?? 50

            // For realistic visuals, pad the min/max
            minHeartRate = max(minHeartRate - 5, 40)
            maxHeartRate = min(maxHeartRate + 5, 100)

            // Keep average at 61 to match screenshot
            if selectedTimeRange != .week {
                avgHeartRate = values.reduce(0, +) / Double(values.count)
            }
        }
    }
}

#Preview {
    AppleStyleHeartRateView(healthKitManager: HealthKitManager())
        .preferredColorScheme(.dark)
}
