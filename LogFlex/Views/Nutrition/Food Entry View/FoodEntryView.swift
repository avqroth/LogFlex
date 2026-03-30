//
//  Untitled.swift
//  LogFlex
//
//  Created by Avery Roth on 5/2/25.
//

import SwiftUI

struct FoodEntryView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @State private var showingAddFoodSheet = false
    @State private var selectedMealTypeFilter: NutritionEntry.MealType? = nil

    var body: some View {
        NavigationView {
            VStack {
                // Meal type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterButton(title: "All", isSelected: selectedMealTypeFilter == nil) {
                            selectedMealTypeFilter = nil
                        }

                        ForEach(NutritionEntry.MealType.allCases, id: \.self) { mealType in
                            FilterButton(title: mealType.rawValue, isSelected: selectedMealTypeFilter == mealType) {
                                selectedMealTypeFilter = mealType
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                // Food entries list
                List {
                    ForEach(filteredEntries) { entry in
                        NavigationLink(destination: FoodEntryDetailView(nutritionManager: nutritionManager, entry: entry)) {
                            FoodEntryRow(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntry)
                }
                .listStyle(InsetGroupedListStyle())

                // Macro summary at bottom of view
                MacroSummaryBar(nutritionManager: nutritionManager)
            }
            .navigationTitle("Food Log")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddFoodSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddFoodSheet) {
                AddFoodView(nutritionManager: nutritionManager)
            }
        }
    }

    var filteredEntries: [NutritionEntry] {
        let todayEntries = nutritionManager.todayEntries
        if let filter = selectedMealTypeFilter {
            return todayEntries.filter { $0.mealType == filter }
        } else {
            return todayEntries
        }
    }

    func deleteEntry(at offsets: IndexSet) {
        // Convert filtered indices to actual indices in the main array
        let entriesToDelete = offsets.map { filteredEntries[$0] }
        for entry in entriesToDelete {
            if let index = nutritionManager.entries.firstIndex(where: { $0.id == entry.id }) {
                nutritionManager.entries.remove(at: index)
            }
        }
        nutritionManager.saveData()
    }
}
