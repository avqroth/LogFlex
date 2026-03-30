


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
