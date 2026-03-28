//
//  HistoricalDataView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/20/25.
//

import SwiftUI
import Charts

struct HistoricalDataView: View {
    let healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var timeRange = 0 // Default to "Day" (24 hours)
    @State private var allTimeSteps: [HistoricalDataPoint] = []
    @State private var allTimeCalories: [HistoricalDataPoint] = []
    @State private var isLoading = true

    // Updated time ranges
    private let timeRanges = ["Day", "Week", "Month", "Year"]

    private func calculateTotal(for dataPoints: [HistoricalDataPoint]) -> Double {
        dataPoints.reduce(0) { $0 + $1.value }
    }

    struct HistoricalDataPoint: Identifiable {
        var id = UUID()
        var date: Date
        var value: Double
        var label: String

        init(date: Date, value: Double) {
            self.date = date
            self.value = value

            let formatter = DateFormatter()
            let calendar = Calendar.current

            // Check if we're showing hourly data (for 24-hour view)
            if calendar.isDate(date, equalTo: Date(), toGranularity: .day) ||
               calendar.isDateInYesterday(date) {
                // For hourly data from past 24 hours
                formatter.dateFormat = "ha" // Format as 1PM, 2PM, etc.
                self.label = formatter.string(from: date).lowercased()
            } else {
                // For daily, weekly, monthly data
                let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0

                if days < 7 {
                    formatter.dateFormat = "E" // Mon, Tue, etc.
                } else if days < 30 {
                    formatter.dateFormat = "d" // 15, 16, etc.
                } else {
                    formatter.dateFormat = "MMM" // Jan, Feb, etc.
                }

                self.label = formatter.string(from: date)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
                        .frame(height: 10)

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

                            Text(timeRange == 0 ? "Past 24 Hours" : timeRanges[timeRange])
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

                        // Stats cards for all time ranges
                        statsCardsView()
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding()

                    Spacer()
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
                // Adding additional padding at the top of the content
                .padding(.top, 10)
                .onAppear {
                    fetchHistoricalData()
                }
            }
        }
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    // Function to calculate statistics
    private func calculateStats(for dataPoints: [HistoricalDataPoint]) -> (min: Double, max: Double, avg: Double) {
        guard !dataPoints.isEmpty else { return (0, 0, 0) }

        let minValue = dataPoints.min(by: { $0.value < $1.value })?.value ?? 0
        let maxValue = dataPoints.max(by: { $0.value < $1.value })?.value ?? 0
        let avgValue = dataPoints.reduce(0) { $0 + $1.value } / Double(dataPoints.count)

        return (minValue, maxValue, avgValue)
    }

    // Stats cards view
    private func statsCardsView() -> some View {
        let dataPoints = selectedTab == 0 ? allTimeSteps : allTimeCalories
        let stats = calculateStats(for: dataPoints)
        let title = selectedTab == 0 ? "Steps" : "Calories"
        let cardColor = selectedTab == 0 ? Color.stand.opacity(0.2) : Color.accent.opacity(0.2)
        let textColor = selectedTab == 0 ? Color.stand : Color.accent

        // Get unit label based on time range
        let unitLabel = timeRange == 0 ? "Hourly" : "Daily"

        return VStack(spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            HStack(spacing: 12) {
                // Minimum Card
                StatCardView(
                    title: "Min",
                    value: selectedTab == 0 ? formatNumber(Int(stats.min)) : String(format: "%.1f", stats.min),
                    subtitle: title,
                    backgroundColor: cardColor,
                    textColor: textColor
                )

                // Maximum Card
                StatCardView(
                    title: "Max",
                    value: selectedTab == 0 ? formatNumber(Int(stats.max)) : String(format: "%.1f", stats.max),
                    subtitle: title,
                    backgroundColor: cardColor,
                    textColor: textColor
                )
            }

            HStack(spacing: 12) {
                // Average Card - label changes based on time range
                StatCardView(
                    title: "\(unitLabel) Avg",
                    value: selectedTab == 0 ? formatNumber(Int(stats.avg)) : String(format: "%.1f", stats.avg),
                    subtitle: title,
                    backgroundColor: cardColor,
                    textColor: textColor
                )

                // Total Card
                StatCardView(
                    title: "Total",
                    value: selectedTab == 0 ? formatNumber(Int(calculateTotal(for: dataPoints))) :
                        String(format: "%.1f", calculateTotal(for: dataPoints)),
                    subtitle: title,
                    backgroundColor: cardColor,
                    textColor: textColor
                )
            }
        }
    }

    // Individual stat card component
    private struct StatCardView: View {
        let title: String
        let value: String
        let subtitle: String
        let backgroundColor: Color
        let textColor: Color

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.headline)
                    .foregroundColor(textColor)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(backgroundColor)
            .cornerRadius(10)
        }
    }

    private func chartsView() -> some View {
        let currentColor = selectedTab == 0 ? Color.stand : Color.accent
        let dataPoints = selectedTab == 0 ? allTimeSteps : allTimeCalories
        let title = selectedTab == 0 ? "Steps" : "Calories"

        // Calculate appropriate width based on number of data points and time range
        // For hourly data (24 points), make each bar a bit narrower
        let pointWidth: CGFloat = timeRange == 0 ? 40 : 50
        let chartWidth = CGFloat(max(UIScreen.main.bounds.width, pointWidth * Double(dataPoints.count)))

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
            .frame(width: chartWidth, height: 250)
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

        // Determine start date and data interval based on selected time range
        let startDate: Date
        let dateInterval: Calendar.Component
        let intervalValue: Int

        switch timeRange {
        case 0: // Day - changed to show past 24 hours instead of just today
            startDate = calendar.date(byAdding: .hour, value: -24, to: today)!
            dateInterval = .hour
            intervalValue = 1
        case 1: // Week
            startDate = calendar.date(byAdding: .day, value: -7, to: today)!
            dateInterval = .day
            intervalValue = 1
        case 2: // Month
            startDate = calendar.date(byAdding: .month, value: -1, to: today)!
            dateInterval = .day
            intervalValue = 1 // Could use 2 or 3 for fewer data points
        case 3: // Year
            startDate = calendar.date(byAdding: .year, value: -1, to: today)!
            dateInterval = .month
            intervalValue = 1
        default:
            startDate = calendar.date(byAdding: .hour, value: -24, to: today)!
            dateInterval = .hour
            intervalValue = 1
        }

        var dates: [Date] = []
        var currentDate = startDate

        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: dateInterval, value: intervalValue, to: currentDate)!
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

