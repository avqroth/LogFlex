//
//  AddWaterView.swift
//  LogFlex
//
//  Created by Avery Roth on 2/13/25.
//

import SwiftUI

struct AddWaterView: View {
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: WaterTrackingViewModel
    @State private var amount: Double = 8

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Stepper(value: $amount, in: 1...64, step: 1) {
                        Text("\(Int(amount)) oz")
                    }
                } header: {
                    Text("Amount")
                }
            }
            .navigationTitle("Add Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        viewModel.addWater(amount)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddWaterView(viewModel: WaterTrackingViewModel())
}
