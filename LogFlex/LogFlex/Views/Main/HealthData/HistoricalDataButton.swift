import SwiftUI
import Charts

struct HistoricalDataButton: View {
    @State private var showHistoricalView = false
    let healthKitManager: HealthKitManager

    var body: some View {
        Button(action: {
            showHistoricalView = true
        }) {
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 18))
                Text("View All-Time Data")
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "arrow.right")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.stand, .accent]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
        .fullScreenCover(isPresented: $showHistoricalView) {
            HistoricalDataView(healthKitManager: healthKitManager)
        }
    }
}

struct HistoricalDataView: View {
    let healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var timeRange = 1
    @State private var allTimeSteps: [HistoricalDataPoint] = []
    @State private var allTimeCalories: [HistoricalDataPoint] = []
    @State private var isLoading = true

    private let timeRanges = ["1 Month", "3 Months", "1 Year"]

    struct HistoricalDataPoint: Identifiable {
        var id = UUID()
        var date: Date
        var value: Double
        var label: String

        init(date: Date, value: Double) {
            self.date = date
            self.value = value

            let formatter = DateFormatter()

            if Calendar.current.isDateInToday(date) {
                formatter.dateFormat = "Today"
                self.label = "Today"
            } else if Calendar.current.isDateInYesterday(date) {
                self.label = "Yesterday"
            } else {
                let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0

                if days < 7 {
                    formatter.dateFormat = "EEE" // Mon, Tue, etc.
                } else if days < 30 {
                    formatter.dateFormat = "d MMM" // 15 Jan
                } else {
                    formatter.dateFormat = "MMM" // Jan, Feb, etc.
                }

                self.label = formatter.string(from: date)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading data...")
                } else {
                    Picker("Time Range", selection: $timeRange) {
                        ForEach(0..<timeRanges.count, id: \.self) { index in
                            Text(timeRanges[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.top)
                    .onChange(of: timeRange) { oldValue, newValue in
                        isLoading = true
                        fetchHistoricalData()
                    }

                    Picker("Data Type", selection: $selectedTab) {
                        Text("Steps").tag(0)
                        Text("Calories").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(selectedTab == 0 ? "Steps Data" : "Calories Data")
                                .font(.headline)

                            Spacer()

                            Text(timeRanges[timeRange])
                                .font(.caption)
                                .padding(6)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.top)
                        .padding(.horizontal)

                        Text("Total: \(selectedTab == 0 ? formatNumber(Int(calculateTotal(for: allTimeSteps))) : formatNumber(Int(calculateTotal(for: allTimeCalories))))")
                            .fontWeight(.semibold)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                            .padding(.horizontal)

                        chartsView()
                            .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding()

                    Spacer()
                }
            }
            .navigationTitle("Historical Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                fetchHistoricalData()
            }
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func calculateTotal(for dataPoints: [HistoricalDataPoint]) -> Double {
        dataPoints.reduce(0) { $0 + $1.value }
    }

    private func chartsView() -> some View {
        let currentColor = selectedTab == 0 ? Color.stand : Color.accent
        let dataPoints = selectedTab == 0 ? allTimeSteps : allTimeCalories
        let title = selectedTab == 0 ? "Steps" : "Calories"

        return ScrollView(.horizontal, showsIndicators: false) {
            Chart {
                ForEach(dataPoints) { point in
                    BarMark(
                        x: .value("Date", point.label),
                        y: .value(title, point.value)
                    )
                    .foregroundStyle(currentColor)
                    .cornerRadius(8)
                }
            }
            .frame(width: CGFloat(max(UIScreen.main.bounds.width, 60 * Double(dataPoints.count))), height: 350)
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(.system(size: 12, weight: .medium))
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks {
                    AxisValueLabel()
                        .font(.system(size: 12, weight: .medium))
                    AxisGridLine()
                }
            }
            .padding(.vertical, 20)
        }
    }

    private func fetchHistoricalData() {
        isLoading = true

        let calendar = Calendar.current
        let today = Date()

        let startDate: Date
        switch timeRange {
        case 0: // 1 Month
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        case 1: // 3 Months
            startDate = calendar.date(byAdding: .month, value: -3, to: today)!
        case 2: // 1 Year
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
        default:
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        }

        var dates: [Date] = []
        var currentDate = startDate

        let dateInterval: Calendar.Component
        switch timeRange {
        case 0: // 1 Month
            dateInterval = .day
        case 1: // 3 Months
            dateInterval = .weekOfYear
        case 2: // 1 Year
            dateInterval = .month
        default:
            dateInterval = .day
        }

        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: dateInterval, value: 1, to: currentDate)!
        }

        let dispatchGroup = DispatchGroup()

        var steps: [HistoricalDataPoint] = []
        var calories: [HistoricalDataPoint] = []

        for date in dates {
            dispatchGroup.enter()
            healthKitManager.fetchSteps(for: date) { stepCount in
                steps.append(HistoricalDataPoint(date: date, value: Double(stepCount)))
                dispatchGroup.leave()
            }

            dispatchGroup.enter()
            healthKitManager.fetchCalories(for: date) { calorieCount in
                calories.append(HistoricalDataPoint(date: date, value: calorieCount))
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            self.allTimeSteps = steps.sorted(by: { $0.date < $1.date })
            self.allTimeCalories = calories.sorted(by: { $0.date < $1.date })
            self.isLoading = false
        }
    }
}
