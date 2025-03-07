//
//  WorkoutCardf.swift
//  LogFlex
//
//  Created by Avery Roth on 1/3/25.
//

import SwiftUI

struct WorkoutCard: View {
   let type: Cardio.CardioType
   let isSelected: Bool
   let action: () -> Void
   let mainColor = Color.main

   var body: some View {
       Button(action: action) {
           VStack {
               Image(systemName: type.icon)
                   .font(.system(size: 30))
                   .foregroundColor(isSelected ? .white : mainColor)
                   .padding(.bottom, 5)

               Text(type.rawValue)
                   .font(.headline)
                   .foregroundColor(isSelected ? .white : .primary)
           }
           .frame(maxWidth: .infinity)
           .frame(height: 120)
           .background(
               RoundedRectangle(cornerRadius: 12)
                   .fill(isSelected ? mainColor : Color(.systemGray6))
           )
       }
   }
}
