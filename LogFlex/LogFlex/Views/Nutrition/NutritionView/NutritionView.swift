//
//  Nutrition.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct NutritionView: View {
    @StateObject var nutritionManager = NutritionManager()
    @State private var showingAddFoodSheet = false
    @State private var showingGoalEditor = false
    @Environment(\.modelContext) private var modelContext


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Nutrition Tracking")
                            .font(.title2)
                            .fontWeight(.bold)

                        Spacer()

                        HStack(spacing: 16) {
                            NavigationLink(destination: NutritionHistoryView(nutritionManager: nutritionManager)) {
                                Image(systemName: "calendar")
                                    .font(.title3)
                                    .foregroundColor(.blue)
                            }

                            Button(action: {
                                showingAddFoodSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    NutritionProgressCard(nutritionManager: nutritionManager)
                        .padding(.horizontal)
                        .padding(.bottom)

                    Text("Today's Meals")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.bottom)

                    todayMealsList
                        .padding(.bottom, 10)
                }
            }
            .navigationTitle("Nutrition")
        }
        .sheet(isPresented: $showingAddFoodSheet) {
            AddFoodView(nutritionManager: nutritionManager)
        }
    }

    private var todayMealsList: some View {
        VStack(spacing: 10) {
            ForEach(nutritionManager.todayEntries) { entry in
                NavigationLink(destination: FoodEntryDetailView(nutritionManager: nutritionManager, entry: entry)) {
                    CompactFoodEntryRow(entry: entry)
                }
            }

            if nutritionManager.todayEntries.isEmpty {
                EmptyFoodEntryCard()
            }

            NavigationLink(destination: FoodLogView(nutritionManager: nutritionManager)) {
                HStack {
                    Text("View Complete Food Log")
                        .font(.subheadline)
                        .foregroundColor(.blue)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
        }
    }

}

#Preview {
    NutritionView()
}
