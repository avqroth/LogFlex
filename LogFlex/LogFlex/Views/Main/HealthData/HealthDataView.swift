////
////  HealthDataView.swift
////  LogFlex
////
////  Created by Avery Roth on 4/29/25.
////
//
//
////
////  HealthProgressCircle.swift
////  LogFlex
////
////  Created by Avery Roth on 10/3/24.
////
//
//import SwiftUI
//
//struct HealthDataView: View {
//    @ObservedObject var healthKitManager: HealthKitManager
//
//    var body: some View {
//        VStack(spacing: 25) {
//            // Title
//            Text("Today's Activity")
//                .font(.title2)
//                .fontWeight(.bold)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding(.horizontal)
//
//            // Progress circles
//            HStack(spacing: 20) {
//                ActivityProgressCircle(
//                    title: "Steps",
//                    value: formatNumber(healthKitManager.stepCount),
//                    progress: healthKitManager.progress,
//                    icon: "figure.walk",
//                    color: .blue // Using .blue instead of .stand
//                )
//
//                ActivityProgressCircle(
//                    title: "Calories",
//                    value: formatNumber(Int(healthKitManager.caloriesBurned)),
//                    progress: healthKitManager.caloriesProgress,
//                    icon: "flame.fill",
//                    color: .orange // Using .orange instead of .accent
//                )
//
//                ActivityProgressCircle(
//                    title: "Stand",
//                    value: "\(healthKitManager.standHours)",
//                    progress: min(Double(healthKitManager.standHours) / 12.0, 1.0), // Assuming 12-hour goal
//                    icon: "figure.stand",
//                    color: .green // Using .green instead of .main
//                )
//            }
//            .padding(.horizontal)
//        }
//        .padding(.vertical)
//    }
//
//    private func formatNumber(_ number: Int) -> String {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
//    }
//}
//
//struct ActivityProgressCircle: View {
//    let title: String
//    let value: String
//    let progress: Double
//    let icon: String
//    let color: Color
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Progress circle
//            ZStack {
//                // Background circle
//                Circle()
//                    .stroke(
//                        color.opacity(0.2),
//                        lineWidth: 10
//                    )
//
//                // Progress circle
//                Circle()
//                    .trim(from: 0, to: min(progress, 1.0))
//                    .stroke(
//                        color,
//                        style: StrokeStyle(
//                            lineWidth: 10,
//                            lineCap: .round
//                        )
//                    )
//                    .rotationEffect(.degrees(-90))
//                    .animation(.easeOut, value: progress)
//
//                // Center icon
//                Image(systemName: icon)
//                    .font(.system(size: 28))
//                    .foregroundColor(color)
//            }
//            .frame(width: 100, height: 100)
//
//            // Value
//            Text(value)
//                .font(.title3)
//                .fontWeight(.bold)
//
//            // Title
//            Text(title)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//    }
//}
//
//struct HealthProgressCircle: View {
//    @ObservedObject var healthKitManager: HealthKitManager
//
//    var body: some View {
//        HealthDataView(healthKitManager: healthKitManager)
//    }
//}
//
//// MARK: - Custom Color Extensions
//extension Color {
//    static let stand = Color.blue
//    static let accent = Color.orange
//    static let main = Color.green
//}
//
//// Preview providers
//struct ActivityProgressCircle_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityProgressCircle(
//            title: "Steps",
//            value: "8,546",
//            progress: 0.75,
//            icon: "figure.walk",
//            color: .blue
//        )
//        .previewLayout(.sizeThatFits)
//        .padding()
//    }
//}
//
//struct HealthDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        HealthDataView(healthKitManager: HealthKitManager())
//            .previewLayout(.sizeThatFits)
//    }
//}
