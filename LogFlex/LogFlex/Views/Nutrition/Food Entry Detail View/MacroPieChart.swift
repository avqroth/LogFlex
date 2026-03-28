//
//  MacroPieChart.swift
//  LogFlex
//
//  Created by Avery Roth on 5/4/25.
//

import SwiftUI

struct MacroPieChart: View {
    var protein: Double
    var carbs: Double
    var fat: Double

    private var proteinCalories: Double {
        protein * 4 // 4 calories per gram
    }

    private var carbsCalories: Double {
        carbs * 4 // 4 calories per gram
    }

    private var fatCalories: Double {
        fat * 9 // 9 calories per gram
    }

    private var totalCalories: Double {
        proteinCalories + carbsCalories + fatCalories
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fat slice
                PieSlice(
                    startAngle: .degrees(0),
                    endAngle: .degrees(fatPercentage * 360 / 100),
                    color: .yellow
                )

                // Protein slice
                PieSlice(
                    startAngle: .degrees(fatPercentage * 360 / 100),
                    endAngle: .degrees((fatPercentage + proteinPercentage) * 360 / 100),
                    color: .blue
                )

                // Carbs slice
                PieSlice(
                    startAngle: .degrees((fatPercentage + proteinPercentage) * 360 / 100),
                    endAngle: .degrees(360),
                    color: .green
                )

                // Center circle
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)

                // Total calories
                VStack {
                    Text("\(Int(totalCalories))")
                        .font(.title3)
                        .fontWeight(.bold)

                    Text("calories")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var proteinPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (proteinCalories / totalCalories) * 100
    }

    private var carbsPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (carbsCalories / totalCalories) * 100
    }

    private var fatPercentage: Double {
        guard totalCalories > 0 else { return 0 }
        return (fatCalories / totalCalories) * 100
    }
}

