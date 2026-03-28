//
//  History.swift
//  LogFlex
//
//  Created by Avery Roth on 12/18/24.
//

import SwiftUI

struct HistoryView: View {
    @State private var selectedActivityType: ActivityType? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Activity filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button("All") {
                            selectedActivityType = nil
                        }
                        .buttonStyle(FilterButtonStyle(isSelected: selectedActivityType == nil))

                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Button(type.rawValue) {
                                selectedActivityType = type
                            }
                            .buttonStyle(FilterButtonStyle(isSelected: selectedActivityType == type))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemBackground))

                // Calendar view with filtered workouts
                ScrollView {
                    CalendarView(selectedActivityType: selectedActivityType)
                        .padding(.top)
                        .padding(.horizontal, 25)
                }
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
