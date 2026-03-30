//
//  ExerciseListView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject var viewModel = ExerciseViewModel()
    let mainColor = Color.main

    var body: some View {
        NavigationStack {
                ExerciseContentView(viewModel: viewModel, mainColor: mainColor)
                    .navigationTitle("Exercise Library")
        }
    }
}


#Preview {
    ExerciseListView()
}
