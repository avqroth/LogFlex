//
//  StatView.swift
//  LogFlex
//
//  Created by Avery Roth on 1/3/25.
//

import SwiftUI

struct StatView: View {
   let value: String
   let unit: String
   let icon: String

   var body: some View {
       VStack(spacing: 5) {
           HStack(spacing: 5) {
               Text(value)
                   .font(.title2.bold())
               Text(unit)
                   .font(.caption)
                   .foregroundColor(.gray)
           }

           Image(systemName: icon)
               .foregroundColor(.gray)
       }
       .frame(maxWidth: .infinity)
       .padding(.vertical, 8)
       .background(Color(.systemGray6))
       .cornerRadius(10)
   }
}

#Preview {
    StatView(value: "", unit: "", icon: "")
}
