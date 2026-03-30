//
//  SimpleBeatingHeartView.swift
//  LogFlex
//
//  Created by Avery Roth on 5/1/25.
//

import SwiftUI

struct SimpleBeatingHeartView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    @State private var isRefreshing = false
    @State private var isBeating = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(Int(healthKitManager.heartRate))")
                        .font(.system(size: 44, weight: .bold))
                    + Text(" BPM")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
                
                Text("Current Heart Rate")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            AnimatedBeatingHeartView()
                .padding(.trailing)
            
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct AnimatedBeatingHeartView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            ZStack {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(
                        Animation.easeOut(duration: 0.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    SimpleBeatingHeartView()
}
