//
//  ContentView.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var healthKit: HealthKitManager
    @StateObject var nutritionManager = NutritionManager()
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house")
                        .font(.custom("Avenir.bold", size: 18))
                }
                .environmentObject(healthKit)

            ExerciseLibraryView()
                .tabItem {
                    Label("Library", systemImage: "dumbbell")
                        .font(.custom("Avenir.bold", size: 18))
                }

            AddWorkoutView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                        .font(.custom("Avenir.bold", size: 18))
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                        .font(.custom("Avenir.bold", size: 18))
                }

//            ProfileView()
//                .tabItem {
//                    Label("Profile", systemImage: "person")
//                        .font(.custom("Avenir.bold", size: 22))
//                }

            NutritionView()
                .tabItem {
                    Label("Nutrition", systemImage: "fork.knife.circle")
                        .font(.custom("Avenir.bold", size: 18))
                }
        }
        .accentColor(Color.main)
    }

}

#Preview {
    ContentView()
}
