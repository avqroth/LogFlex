//
//  ExerciseListView.swift
//  LogFlex
//
//  Created by Avery Roth on 12/25/24.
//

import SwiftUI

struct ExerciseListView: View {
    @StateObject var viewModel = ExerciseViewModel()
    @StateObject var subscriptionViewModel = SubscriptionViewModel()
    let mainColor = Color.main

    var body: some View {
        NavigationStack {
            SubscriptionGate(restriction: .freeAccess) {
                ExerciseContentView(viewModel: viewModel, mainColor: mainColor)
                    .navigationTitle("Exercise Library")
            }
        }
    }
}


#Preview {
    ExerciseListView()
}
