//
//  PurchasesDelegateHandler.swift
//  RoundabeatMetronome
//
//  Created by Jessica Estes on 7/13/25.
//

import Foundation
import RevenueCat

class PurchasesDelegateHandler: NSObject, ObservableObject {
    static let shared = PurchasesDelegateHandler()
}

extension PurchasesDelegateHandler: PurchasesDelegate {
    func purchases(_purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        UserViewModel.shared.customerInfo = customerInfo
    }
}
