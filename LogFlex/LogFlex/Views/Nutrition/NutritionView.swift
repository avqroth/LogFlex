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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Macros")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom)

                        Spacer()

                        Button(action: {
                            showingAddFoodSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
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

struct CompactFoodEntryRow: View {
    var entry: NutritionEntry

    var body: some View {
        HStack {
            // Meal icon with background
            ZStack {
                Circle()
                    .fill(mealTypeColor(entry.mealType).opacity(0.2))
                    .frame(width: 36, height: 36)

                Image(systemName: mealTypeIcon(entry.mealType))
                    .font(.system(size: 16))
                    .foregroundColor(mealTypeColor(entry.mealType))
            }

            // Food info
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("\(entry.calories) cal · P: \(Int(entry.protein))g · C: \(Int(entry.carbs))g · F: \(Int(entry.fat))g")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Meal type tag
            Text(entry.mealType.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(mealTypeColor(entry.mealType).opacity(0.2))
                )
                .foregroundColor(mealTypeColor(entry.mealType))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func mealTypeIcon(_ mealType: NutritionEntry.MealType) -> String {
        switch mealType {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        case .snack: return "applelogo"
        }
    }

    private func mealTypeColor(_ mealType: NutritionEntry.MealType) -> Color {
        switch mealType {
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .purple
        case .snack: return .green
        }
    }
}

// Empty state for food log
struct EmptyFoodEntryCard: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .font(.system(size: 30))
                .foregroundColor(.gray)

            Text("No meals logged today")
                .font(.headline)

            Text("Tap + to add your first meal")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

// Nutrition progress compact card
struct NutritionProgressCard: View {
    @ObservedObject var nutritionManager: NutritionManager
    @State private var showingGoalEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Calories row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.headline)

                    Text("\(nutritionManager.todayCalories) / \(nutritionManager.dailyCalorieGoal)")
                        .font(.subheadline)
                }

                Spacer()

                Button(action: {
                    showingGoalEditor = true
                }) {
                    Image(systemName: "gearshape")
                        .foregroundColor(.secondary)
                }
            }

            // Calorie progress bar
            ProgressBar(value: nutritionManager.calorieProgress, color: .orange)
                .frame(height: 10)

            // Macros
            HStack(spacing: 16) {
                // Protein
                MacroProgressItem(
                    title: "Protein",
                    value: "\(Int(nutritionManager.todayProtein))g",
                    progress: nutritionManager.proteinProgress,
                    color: .blue
                )

                // Carbs
                MacroProgressItem(
                    title: "Carbs",
                    value: "\(Int(nutritionManager.todayCarbs))g",
                    progress: nutritionManager.carbsProgress,
                    color: .green
                )

                // Fat
                MacroProgressItem(
                    title: "Fat",
                    value: "\(Int(nutritionManager.todayFat))g",
                    progress: nutritionManager.fatProgress,
                    color: .yellow
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .sheet(isPresented: $showingGoalEditor) {
            NutritionGoalEditorView(nutritionManager: nutritionManager)
        }
    }
}

// Individual macro progress circle
struct MacroProgressItem: View {
    var title: String
    var value: String
    var progress: Double
    var color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 4)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
            }

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Full Food Log View for the navigation destination
struct FoodLogView: View {
    @ObservedObject var nutritionManager: NutritionManager
    @State private var showingAddFoodSheet = false
    @State private var selectedMealTypeFilter: NutritionEntry.MealType? = nil

    var body: some View {
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

    var filteredEntries: [NutritionEntry] {
        let todayEntries = nutritionManager.todayEntries
        if let filter = selectedMealTypeFilter {
            return todayEntries.filter { $0.mealType == filter }
        } else {
            return todayEntries
        }
    }

    func deleteEntry(at offsets: IndexSet) {
        nutritionManager.deleteEntry(at: offsets)
    }
}

#Preview {
    NutritionView()
}
