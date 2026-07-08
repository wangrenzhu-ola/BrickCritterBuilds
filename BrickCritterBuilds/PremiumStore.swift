import Foundation
import StoreKit
import Combine

@MainActor
final class PremiumStore: ObservableObject {
    static let premiumProductID = "com.brickcritter.builds.premium.unlock"

    @Published var products: [Product] = []
    @Published var isPremiumUnlocked: Bool { didSet { UserDefaults.standard.set(isPremiumUnlocked, forKey: premiumKey) } }
    @Published var storeKitMessage = "StoreKit 2 not loaded yet. The first Critter Build remains free."
    @Published var restoreFailureNote: String?

    private let premiumKey = "BrickCritterBuilds.premiumUnlocked"

    init() { isPremiumUnlocked = UserDefaults.standard.bool(forKey: premiumKey) }

    func loadProducts() async {
        do {
            products = try await Product.products(for: [Self.premiumProductID])
            storeKitMessage = products.isEmpty ? "Purchase fallback: local StoreKit catalog unavailable; your Critter Builds stay safe." : "Premium catalog loaded from StoreKit 2."
        } catch {
            storeKitMessage = "Purchase fallback: StoreKit is unavailable. Your first Critter Build stays free."
        }
    }

    func purchasePremium() async {
        guard let product = products.first else {
            storeKitMessage = "Purchase fallback: StoreKit product is unavailable in this environment."
            return
        }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    isPremiumUnlocked = true
                    await transaction.finish()
                    storeKitMessage = "Premium unlocked. Multiple shelf slots, local critter packs, export, and shelf themes are now available."
                } else {
                    storeKitMessage = "Purchase could not be verified; no Critter Build data was changed."
                }
            case .pending:
                storeKitMessage = "Purchase pending. Critter Build data remains local and usable."
            case .userCancelled:
                storeKitMessage = "Purchase canceled. The first Critter Build loop remains available."
            @unknown default:
                storeKitMessage = "Purchase state unknown. No Critter Build data was changed."
            }
        } catch {
            storeKitMessage = "Purchase failed. Try again later; saved Critter Builds are preserved."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result, transaction.productID == Self.premiumProductID { isPremiumUnlocked = true }
            }
            storeKitMessage = isPremiumUnlocked ? "Premium restored." : "No Premium purchase found to restore."
            restoreFailureNote = nil
        } catch {
            restoreFailureNote = "Restore failed. Retry from Paywall; local entitlement state is preserved."
        }
    }
}
