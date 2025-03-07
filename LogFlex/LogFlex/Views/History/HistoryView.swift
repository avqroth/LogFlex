//
//  History.swift
//  LogFlex
//
//  Created by Avery Roth on 12/18/24.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                CalendarView()
                    .padding(.top)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView()
}
