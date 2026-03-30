//
//  SubscriptionService.swift
//  LogFlex
//
//  Created by Avery Roth on 5/12/25.
//

import SwiftUI
import StoreKit

// MARK: - Subscription Service

class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    @Published var products: [Product] = []
    @Published var purchasedSubscriptions: [Product] = []
    @Published var isSubscribed = false
    @Published var isLoading = false
    @Published var hasError = false
    @Published var errorMessage: String?

    private var updateListenerTask: Task<Void, Error>?
    private let productIdentifiers = ["com.logflex.subscription.monthly"]

    init() {
        updateListenerTask = listenForTransactions()

        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    @MainActor
    func loadProducts() async {
        isLoading = true
        hasError = false
        errorMessage = nil

        do {
            products = try await Product.products(for: productIdentifiers)
            if products.isEmpty {
                throw SubscriptionError.noProductsFound
            }
        } catch {
            hasError = true
            errorMessage = handleError(error)
            print("Failed to load products: \(error.localizedDescription)")
        }

        isLoading = false
    }

    @MainActor
    func purchase(_ product: Product) async {
        isLoading = true
        hasError = false
        errorMessage = nil

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    // Successfully purchased
                    await transaction.finish()
                    await updateSubscriptionStatus()
                case .unverified(_, let error):
                    throw error
                }
            case .userCancelled:
                print("User cancelled purchase")
            case .pending:
                print("Purchase pending approval")
            @unknown default:
                throw SubscriptionError.unknown
            }
        } catch {
            hasError = true
            errorMessage = handleError(error)
            print("Failed to purchase: \(error.localizedDescription)")
        }

        isLoading = false
    }

    @MainActor
    func restorePurchases() async {
        isLoading = true
        hasError = false
        errorMessage = nil

        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            hasError = true
            errorMessage = handleError(error)
            print("Failed to restore purchases: \(error.localizedDescription)")
        }

        isLoading = false
    }

    @MainActor
    func updateSubscriptionStatus() async {
        // Get the user's current entitlement status
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if productIdentifiers.contains(transaction.productID) {
                    if let product = products.first(where: { $0.id == transaction.productID }) {
                        if !purchasedSubscriptions.contains(where: { $0.id == product.id }) {
                            purchasedSubscriptions.append(product)
                        }
                    }

                    if transaction.revocationDate == nil && !transaction.isUpgraded {
                        isSubscribed = true
                    }
                }
            case .unverified:
                continue
            }
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction):
                    if self.productIdentifiers.contains(transaction.productID) {
                        await self.updateSubscriptionStatus()
                    }

                    await transaction.finish()
                case .unverified:
                    continue
                }
            }
        }
    }

    private func handleError(_ error: Error) -> String {
        if let subscriptionError = error as? SubscriptionError {
            return subscriptionError.localizedDescription
        }

        let nsError = error as NSError
        if nsError.domain == SKErrorDomain {
            switch nsError.code {
            case 0:
                return "Unknown StoreKit error"
            case 2:
                return "The user has cancelled the payment"
            case 7:
                return "This product is not available in your region"
            case 20:
                return "Device is not authorized to make purchases"
            default:
                return "StoreKit error: \(nsError.localizedDescription)"
            }
        }

        return "Something went wrong: \(error.localizedDescription)"
    }

    enum SubscriptionError: Error, LocalizedError {
        case noProductsFound
        case purchaseFailed
        case notAuthorized
        case unknown

        var errorDescription: String? {
            switch self {
            case .noProductsFound:
                return "No subscription products found"
            case .purchaseFailed:
                return "Failed to purchase subscription"
            case .notAuthorized:
                return "Not authorized to make purchases"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
}

// MARK: - Subscription View Models and Views

class SubscriptionViewModel: ObservableObject {
    @Published var service = SubscriptionService.shared
    @Published var showingPaywall = false

    var monthlySubscription: Product? {
        service.products.first
    }

    var formattedPrice: String {
        if let product = monthlySubscription {
            return product.displayPrice
        }
        return "$4.99"  // Fallback price
    }

    var trialPeriodText: String {
        "7-day free trial, then \(formattedPrice)/month"
    }

    func checkSubscriptionStatus() -> Bool {
        return service.isSubscribed
    }

    func subscribe() async {
        if let product = monthlySubscription {
            await service.purchase(product)
        }
    }

    func restore() async {
        await service.restorePurchases()
    }
}

struct SubscriptionPaywallView: View {
    @ObservedObject var viewModel: SubscriptionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.95).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 15) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 70))
                            .foregroundColor(Color.main)
                            .padding(.top, 40)

                        Text("LogFlex Premium")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Text("Track your fitness journey like a pro")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }

                    // Features
                    VStack(spacing: 20) {
                        featureRow(icon: "checkmark.circle.fill", text: "Unlimited workout routines")
                        featureRow(icon: "checkmark.circle.fill", text: "Access to all exercise library")
                        featureRow(icon: "checkmark.circle.fill", text: "Detailed fitness analytics")
                        featureRow(icon: "checkmark.circle.fill", text: "Custom workout plans")
                        featureRow(icon: "checkmark.circle.fill", text: "Progress tracking")
                    }
                    .padding(.top, 20)

                    Spacer()

                    // Price
                    VStack(spacing: 10) {
                        Text(viewModel.trialPeriodText)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Cancel anytime")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)

                    // Subscribe button
                    Button {
                        Task {
                            await viewModel.subscribe()
                            if viewModel.service.isSubscribed {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Text("Start Free Trial")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .background(Color.main)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)

                    // Restore purchases
                    Button {
                        Task {
                            await viewModel.restore()
                            if viewModel.service.isSubscribed {
                                dismiss()
                            }
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)

                    // Terms and privacy
                    VStack(spacing: 5) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack(spacing: 3) {
                            Link("Terms of Service", destination: URL(string: "https://logflex.com/terms")!)
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("and")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Link("Privacy Policy", destination: URL(string: "https://logflex.com/privacy")!)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                }
                .padding(.horizontal)
            }

            // Loading overlay
            if viewModel.service.isLoading {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(Color.main)

                            Text("Processing...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    )
            }

            // Error alert
//            .alert(isPresented: $viewModel.service.hasError) {
//                Alert(
//                    title: Text("Subscription Error"),
//                    message: Text(viewModel.service.errorMessage ?? "Unknown error"),
//                    dismissButton: .default(Text("OK"))
//                )
//            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color.main)

            Text(text)
                .font(.body)
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Subscription Access Control

struct SubscriptionGate<Content: View>: View {
    @StateObject private var viewModel = SubscriptionViewModel()

    let content: Content
    let restriction: SubscriptionRestriction

    init(restriction: SubscriptionRestriction = .fullAccess, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.restriction = restriction
    }

    var body: some View {
        ZStack {
            if viewModel.checkSubscriptionStatus() || restriction == .freeAccess {
                content
            } else {
                restrictedAccessView
            }
        }
        .sheet(isPresented: $viewModel.showingPaywall) {
            SubscriptionPaywallView(viewModel: viewModel)
        }
    }

    private var restrictedAccessView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.circle")
                .font(.system(size: 70))
                .foregroundColor(Color.main)

            Text("Premium Feature")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unlock all features with LogFlex Premium")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                viewModel.showingPaywall = true
            } label: {
                Text("Upgrade to Premium")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.main)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum SubscriptionRestriction {
    case freeAccess    // Available to all users
    case fullAccess    // Requires subscription
}

// MARK: - App Integration

// Update ExerciseListView to check for subscription status

// Use SubscriptionGate for your premium features
struct PremiumFeatureView: View {
    var body: some View {
        SubscriptionGate(restriction: .fullAccess) {
            // Your premium content here
            Text("Premium content available!")
        }
    }
}
