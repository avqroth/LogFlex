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
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Home", systemImage: "house")
                        .font(.custom("Avenir.bold", size: 22))
                }
                .environmentObject(healthKit)

            ExerciseLibraryView()
                .tabItem {
                    Label("Library", systemImage: "square.grid.2x2")
                        .font(.custom("Avenir.bold", size: 22))
                }

            AddWorkoutView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle")
                        .font(.custom("Avenir.bold", size: 22))
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                        .font(.custom("Avenir.bold", size: 22))
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                        .font(.custom("Avenir.bold", size: 22))
                }

            Text("Hello")
        }
    }

}

#Preview {
    ContentView()
}
