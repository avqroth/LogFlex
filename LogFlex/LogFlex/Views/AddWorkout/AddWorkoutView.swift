//
//  AddWorkoutView.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI
import Foundation

struct AddWorkoutView: View {
   @State private var showWorkoutSheet = false

   var body: some View {
       NavigationStack {
           ScrollView {
               VStack(spacing: 0) {
                   VStack(spacing: 15) {
                       Button(action: { showWorkoutSheet = true }) {
                           HStack {
                               Image(systemName: "plus.circle.fill")
                                   .font(.title2)
                               Text("Start Empty Workout")
                                   .font(.headline)
                               Spacer()
                               Image(systemName: "chevron.right")
                                   .foregroundStyle(.main)
                           }
                           .padding()
                           .background(Color(.systemBackground))
                           .cornerRadius(12)
                       }
                       .foregroundStyle(Color.main)
                   }
                   .padding()
               }
           }
           .background(Color(.systemGroupedBackground))
           .sheet(isPresented: $showWorkoutSheet) {
               WorkoutNavigationView()
           }
           .navigationTitle("Add Workout")
       }
   }
}

struct WorkoutNavigationView: View {
   @Environment(\.dismiss) private var dismiss

   var body: some View {
       NavigationStack {
           CustomWorkout(showWorkoutSheet: .constant(true))
               .navigationBarTitleDisplayMode(.inline)
       }
   }
}

#Preview {
    AddWorkoutView()
}
