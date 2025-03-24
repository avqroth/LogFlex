

import SwiftUI

struct WorkoutSummaryView: View {
    let workout: WorkoutLog
    @State private var showingDetail = false

    var body: some View {
        Button {
            showingDetail.toggle()
        } label: {
            HStack {
                Text(workout.name)
                    .font(.headline)
                    .foregroundStyle(.accent)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.accent)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            DetailedWorkoutView(workout: workout)
        }
    }
}


