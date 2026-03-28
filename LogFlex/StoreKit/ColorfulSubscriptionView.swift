//
//  ColorfulSubscriptionView.swift
//  LogFlex
//
//  Created by Avery Roth on 4/28/25.
//

import SwiftUI

struct ColorfulSubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedPlan = 1
    @State private var selectedFeatureCategory = 0

    // Subscription Plans
    private let plans = ["Basic", "Pro", "Premium"]
    private let planColors: [Color] = [.blue, .purple, .pink]
    private let planIcons = ["star.fill", "stars.fill", "sparkles"]
    private let planPrices = ["$2.99/mo", "$4.99/mo", "$9.99/mo"]

    // Feature Categories
    private let featureCategories = ["Health Stats", "Workouts"]
    private let categoryIcons = ["heart.fill", "figure.run"]
    private let categoryColors: [Color] = [.red, .green]

    // Premium Features by Category
    private let premiumFeatures: [[String]] = [
        // Health Stats Features
        [
            "Detailed heart rate data and zones",
            "Full access to historical health stats",
            "Advanced health analytics and insights",
            "Personalized health reports"
        ],
        // Workout Features
        [
            "Access to all past workout history",
            "Unlimited workout logging",
            "Advanced workout metrics and analysis",
            "Custom workout planning tools"
        ]
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.indigo.opacity(0.1), .purple.opacity(0.1), .pink.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Colorful Header
                    VStack(spacing: 12) {
                        ZStack {
                            // Decorative circles
                            Circle()
                                .fill(Color.blue.opacity(0.7))
                                .frame(width: 120, height: 120)
                                .offset(x: -100, y: -20)

                            Circle()
                                .fill(Color.purple.opacity(0.7))
                                .frame(width: 100, height: 100)
                                .offset(x: 80, y: -40)

                            Circle()
                                .fill(Color.pink.opacity(0.7))
                                .frame(width: 80, height: 80)
                                .offset(x: 50, y: 40)

                            // Centered icon with shimmer effect
                            Image(systemName: "crown.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(
                                    .linearGradient(
                                        colors: [.yellow, .orange, .yellow],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: .orange.opacity(0.5), radius: 10)
                        }
                        .frame(height: 120)

                        Text("Unlock Premium Features")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Text("Get access to all features and unlimited history")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Feature Category Selector
                    VStack(spacing: 15) {
                        Text("What You'll Get")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        HStack(spacing: 15) {
                            ForEach(0..<featureCategories.count, id: \.self) { index in
                                Button(action: {
                                    withAnimation {
                                        selectedFeatureCategory = index
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: categoryIcons[index])
                                            .foregroundColor(categoryColors[index])

                                        Text(featureCategories[index])
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        Capsule()
                                            .fill(selectedFeatureCategory == index ?
                                                categoryColors[index].opacity(0.15) : Color(.systemGray6))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)

                        // Features List
                        VStack(alignment: .leading, spacing: 15) {
                            ForEach(0..<premiumFeatures[selectedFeatureCategory].count, id: \.self) { index in
                                HStack(spacing: 15) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(categoryColors[selectedFeatureCategory])

                                    Text(premiumFeatures[selectedFeatureCategory][index])
                                        .font(.body)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 5)
                        )
                        .padding(.horizontal)
                    }

                    // Plan Selector Cards
                    VStack(spacing: 15) {
                        Text("Choose Your Plan")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)

                        ForEach(0..<plans.count, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedPlan = index
                                }
                            }) {
                                HStack(spacing: 15) {
                                    // Icon with colorful background
                                    ZStack {
                                        Circle()
                                            .fill(planColors[index].opacity(0.2))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: planIcons[index])
                                            .font(.system(size: 22))
                                            .foregroundColor(planColors[index])
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(plans[index])
                                            .font(.headline)

                                        // Create different descriptions based on plan level
                                        if index == 0 {
                                            Text("Basic premium features + 30 days history")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        } else if index == 1 {
                                            Text("All features + 90 days history")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("All features + unlimited history")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    Text(planPrices[index])
                                        .font(.headline)
                                        .foregroundColor(planColors[index])
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(selectedPlan == index ? planColors[index] : Color.clear, lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .fill(Color(.systemBackground))
                                        )
                                )
                                .shadow(color: selectedPlan == index ? planColors[index].opacity(0.3) : Color.gray.opacity(0.1), radius: 5)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)

                    // Subscription button
                    Button(action: {
                        // This would normally activate the subscription
                        // For now, just go back
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Start 7-Day Free Trial")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [planColors[selectedPlan], planColors[selectedPlan].opacity(0.7)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    // Back button with fun styling
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                                .font(.body)
                            Text("Maybe Later")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.secondary)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 25)
            }
        }
    }
}

extension Color {
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [.blue, .purple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let secondaryGradient = LinearGradient(
        gradient: Gradient(colors: [.orange, .pink]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    ColorfulSubscriptionView()
}
