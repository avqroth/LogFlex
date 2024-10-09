//
//  MainViewswift.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI

//struct MainView: View {
//    @State private var greeting: String = ""
//    let sampleWorkoutDays: [WorkoutDay] = (1...30).map { day in
//            WorkoutDay(day: day, hasWorkout: [1, 3, 5, 7, 10, 12, 15, 18, 20, 22, 25, 28].contains(day))
//        }
//
//    var body: some View {
//        ScrollView {
//            VStack {
//                Text(greeting)
//                    .font(.custom("Avenir", size: 25))
//                    .padding(.trailing,150)
//                    .onAppear(perform: updateGreeting)
//
//                Spacer(minLength: 50)
//
//                Text("History")
//                    .padding(.trailing, 250)
//                WorkoutCalendarView(
//                    workoutDays: sampleWorkoutDays,
//                    currentMonth: "September 2024",
//                    daysInMonth: 30,
//                    firstWeekday: 0
//                )
//                Spacer()
//
//            }
//        }
//    }
//
//    private func updateGreeting() {
//        let hour = Calendar.current.component(.hour, from: Date())
//
//        switch hour {
//        case 0..<12:
//            greeting = "Good morning!"
//        case 12..<17:
//            greeting = "Good afternoon!"
//        default:
//            greeting = "Good evening!"
//        }
//    }
//}

struct MainView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var greeting: String = ""
    @State private var progress: Double = 0.0
    @State private var steps: Int = 0
    @StateObject private var viewModel = CircleViewModel()

    var body: some View {
        ScrollView {
            Text(greeting)
                .font(.largeTitle)
                .font(.largeTitle)
                .padding(.top, 35)
                .padding(.trailing, 100)
                .onAppear(perform: updateGreeting)
                .padding(.top, 25)

            Spacer(minLength: 50)
            
            VStack {
                HealthProgressCircle(healthKitManager: healthKitManager)
            }
            .padding()

            HStack {
                ForEach(viewModel.circleData) { circle in
                    CircleView(data: circle)
                }
            }
        }
        .onAppear {
            healthKitManager.fetchTodaySteps()
        }
    }
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())

        switch hour {
        case 0..<12:
            greeting = "Good Morning!"
        case 12..<17:
            greeting = "Good Afternoon!"
        default:
            greeting = "Good Evening!"
        }
    }
}



#Preview {
    MainView()
        .environmentObject(HealthKitManager())
}
