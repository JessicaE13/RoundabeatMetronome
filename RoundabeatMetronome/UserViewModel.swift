//
//  UserViewModel.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/13/25.
//

import Foundation
import SwiftUI
import RevenueCat

// Static shared model for UserView

class UserViewModel: ObservableObject {
    static let shared = UserViewModel()

// The latest customer info from RevenueCat. Updated by PurchaseDelegate whenever the Purchases SDK updates the cache
    @Published var customerInfo: CustomerInfo? {
        didSet {
            subscriptionActive = customerInfo?.entitlements[Constants.entitlementId]?.isActive == true
        }
    }

// The latest offerings - fetched from YourAppNameApp.Swift on app launch
    @Published var offerings: Offerings? = nil

// Set from the didSet method of customerInfo above, based on the entitlement set in Constants.swift
@Published var subscriptionActive: Bool = false

// These functions mimic displaying a login dialog, identifying the user, then logging out later.
    func login(userId: String) {
        Purchases.shared.login(userId) { _, _, _ in }
    }
    
    func logout() {
        Purchases.shared.logOut(completion: nil)
    }
}
