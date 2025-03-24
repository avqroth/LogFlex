//
//  WaterTrackingCard.swift
//  LogFlex
//
//  Created by Avery Roth on 2/13/25.
//

import SwiftUI
import SwiftData

struct WaterTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = WaterTrackingViewModel()
    @Query(sort: \WaterLog.date, order: .reverse) private var waterLogs: [WaterLog]
    @State private var showingHistory = false
    @State private var customAmount: String = ""
    @State private var showingCustomAmountSheet = false

    private let quickAddAmounts = [8.0, 12.0, 16.0, 20.0]

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Water Intake")
                        .font(.title2)
                        .bold()
                    Text("\(Int(viewModel.todayIntake))oz of \(Int(viewModel.dailyGoal))oz")
                        .foregroundStyle(Color.main)
                }

                Spacer()

                CircularProgressView(progress: viewModel.progressPercentage / 100)
                    .frame(width: 60, height: 60)
            }

            ProgressView(value: viewModel.progressPercentage, total: 100)
                .tint(Color.main)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Add")
                    .font(.headline)

                HStack(spacing: 12) {
                    ForEach(quickAddAmounts, id: \.self) { amount in
                        Button(action: {
                            addWater(amount)
                        }) {
                            Text("\(Int(amount))")
                                .font(.callout)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(Color.main)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }

                    Button(action: {
                        showingCustomAmountSheet = true
                    }) {
                        Image(systemName: "plus")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .foregroundColor(Color.main)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Today's Entries")
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        showingHistory.toggle()
                    }) {
                        Image(systemName: showingHistory ? "chevron.up" : "chevron.down")
                            .foregroundStyle(.secondary)
                    }
                }

                if showingHistory {
                    ScrollView {
                        VStack(spacing: 8) {
                            if todayWaterLogs.isEmpty {
                                Text("No entries today")
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 4)
                            } else {
                                if todayWaterLogs.count > 0 {
                                    waterLogRow(todayWaterLogs[0])
                                    Divider()
                                }

                                if todayWaterLogs.count > 1 {
                                    waterLogRow(todayWaterLogs[1])
                                    Divider()
                                }

                                if todayWaterLogs.count > 2 {
                                    waterLogRow(todayWaterLogs[2])
                                    Divider()
                                }

                                if todayWaterLogs.count > 3 {
                                    waterLogRow(todayWaterLogs[3])
                                    Divider()
                                }

                                if todayWaterLogs.count > 4 {
                                    waterLogRow(todayWaterLogs[4])
                                    if todayWaterLogs.count > 5 {
                                        Divider()
                                    }
                                }

                                if todayWaterLogs.count > 5 {
                                    Text("+ \(todayWaterLogs.count - 5) more entries")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 4)
                                }
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .onAppear {
            loadTodayWater()
        }
        .sheet(isPresented: $showingCustomAmountSheet) {
            NavigationStack {
                Form {
                    Section("Custom Amount") {
                        TextField("Amount in oz", text: $customAmount)
                            .keyboardType(.decimalPad)
                    }
                }
                .navigationTitle("Add Water")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingCustomAmountSheet = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") {
                            if let amount = Double(customAmount) {
                                addWater(amount)
                            }
                            showingCustomAmountSheet = false
                            customAmount = ""
                        }
                    }
                }
            }
        }
    }

    private func waterLogRow(_ log: WaterLog) -> some View {
        HStack {
            Text("\(Int(log.amount))oz")
                .font(.subheadline)

            Text(log.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button {
                deleteWaterLog(log)
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private var todayWaterLogs: [WaterLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return waterLogs.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }

    private func loadTodayWater() {
        viewModel.todayIntake = todayWaterLogs.reduce(0) { $0 + $1.amount }
    }

    private func addWater(_ amount: Double) {
        let log = WaterLog(amount: amount)
        modelContext.insert(log)
        viewModel.addWater(amount)
    }

    private func deleteWaterLog(_ log: WaterLog) {
        modelContext.delete(log)
        viewModel.removeWater(log.amount)
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(.systemGray5),
                    lineWidth: 8
                )
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.main,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut, value: progress)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .bold()
        }
    }
}

#Preview {
    WaterTrackingView()
}
