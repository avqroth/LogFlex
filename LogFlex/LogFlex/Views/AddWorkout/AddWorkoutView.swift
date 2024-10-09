//
//  AddWorkoutView.swift
//  LogFlex
//
//  Created by Avery Roth on 9/24/24.
//

import SwiftUI
import Foundation

struct AddWorkoutView: View {
    let mainColor = Color.main
    let secondaryColor = Color.backup
    @StateObject private var viewModel = CapsuleViewModel()

    var body: some View {
        ScrollView {
            HStack {
                Text("Today's Workout")
                    .font(.largeTitle)
                    .padding(.top, 35)
                    .padding(.trailing, 100)
            }
            HStack {
                Text("What did we do today?")
                    .font(.headline)
                    .padding(.top, 1)
                    .padding(.trailing, 160)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.capsuleData) { capsule in
                        CapsuleView(data: capsule)
                    }
                }
            }.padding(.leading, 10)

            Spacer(minLength: 25)

            ZStack {
                VStack {
                    Rectangle()
                        .frame(width: 350, height: 200)
                        .foregroundStyle(mainColor)
                        .clipShape(.rect(cornerRadius: 35))


                }
            }
        }
    }
}

#Preview {
    AddWorkoutView()
}
