//
//  SearchFilterBar.swift
//  LogFlex
//
//  Created by Avery Roth on 5/5/25.
//

import SwiftUI

struct SearchFilterBar: View {
    @ObservedObject var viewModel: ExerciseViewModel
    let mainColor: Color

    var body: some View {
        HStack {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search exercises", text: $viewModel.searchText)
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(18)

            // Muscle Filter Menu
            Menu {
                Button("All Muscles", action: { viewModel.selectedMuscle = "" })
                ForEach(viewModel.muscleGroups, id: \.self) { muscle in
                    Button(muscle.capitalized) {
                        viewModel.selectedMuscle = muscle
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .foregroundColor(.accent)
                    .font(.title2)
            }
        }
    }
}

