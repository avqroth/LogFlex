//
//  AddExerciseButton.swift
//  LogFlex
//
//  Created by Avery Roth on 1/17/25.
//

import SwiftUI

struct AddExerciseButton: View {
    @Binding var exercises: [ExerciseLog]
    @State private var showingExerciseInput = false

    var body: some View {
        Button(action: { showingExerciseInput = true }) {
            Label("Add Exercise", systemImage: "plus.circle.fill")
                .foregroundStyle(Color.main)
        }
        .sheet(isPresented: $showingExerciseInput) {
            AddExerciseView(exercises: $exercises)
        }
    }
}


