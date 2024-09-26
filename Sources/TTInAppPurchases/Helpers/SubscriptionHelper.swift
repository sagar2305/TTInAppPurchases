//
//  SubscriptionHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 7/29/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit
import RevenueCat
import Amplitude
import StoreKit

enum OfferingIdentifier: String, CaseIterable {
    case firstNumber = "firstnumber"
    case secondNumber = "secondnumber"
    case thirdNumber = "thirdnumber"
    case fourthNumber = "fourthnumber"

    var entitlement: String {
        switch self {
        case .firstNumber:
            return "firstNumberPro"
        case .secondNumber:
            return "secondNumberPro"
        case .thirdNumber:
            return "thirdNumberPro"
        case .fourthNumber:
            return "fourthNumberPro"
        }
    }
}


public class SubscriptionHelper {
    
    public enum InAppPurchaseError: Error {
        case noProductsAvailable
        case purchaseFailed
        case userCancelledPurchase
    }
    
    public static let shared = SubscriptionHelper()
    public typealias CompletionHandler = (_ product: [IAPProduct]?, _ error: InAppPurchaseError?) -> Void
    public typealias PurchaseCompletion = (_ success: Bool, _ error: InAppPurchaseError?) -> Void
    public typealias ProUserStatusCompletion = (_ isProUser: Bool) -> Void
    public typealias ProductsCompletionHandler = (_ offeringIdentifier: String?, _ products: [IAPProduct]?, _ error: InAppPurchaseError?) -> Void

    private init() {
        _refreshPurchaseInfo()
    }
    
    // Private property to store subscription status
    private var _isProUser: Bool = false

    // Boolean to indicate if purchase info has been refreshed
    private var _isPurchaseInfoRefreshed: Bool = false

    private var _countryCode: String? {
        return SKPaymentQueue.default().storefront?.countryCode
    }
    
    public func countryCode() -> String? {
        return _countryCode
    }
    
    private func _process(purchaserInfo: CustomerInfo?) {
        guard let purchaserInfo = purchaserInfo else {
            self._isProUser = false // Assume non-pro status if no info available
            return
        }
        
        // Update _isProUser based on the entitlement status
        self._isProUser = purchaserInfo.entitlements.all["pro"]?.isActive ?? false
    }
    
    static public func attributedFeatureText(_ feature: String) -> String {
            return "✓  " + feature
    }
    
    private func _refreshPurchaseInfo(completion: ProUserStatusCompletion? = nil) {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let error = error {
                // Handle error appropriately, maybe log or show an alert
                print("Failed to fetch customer info: \(error.localizedDescription)")
                completion?(self._isProUser) // Return current state on error
                return
            }
            self._process(purchaserInfo: customerInfo)
            // Set the flag to true after processing
            self._isPurchaseInfoRefreshed = true
            completion?(self._isProUser) // Return updated status
        }
    }

    public func isProUser(completion: @escaping ProUserStatusCompletion) {
        if _isPurchaseInfoRefreshed {
            // If purchase info is already refreshed, return immediately
            completion(self._isProUser)
        } else {
            // Refresh purchase info and call the completion handler once it's done
            _refreshPurchaseInfo(completion: completion)
        }
    }

    public func restorePurchases(_ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.restorePurchases { [weak self] (purchaserInfo, error) in
            guard let self = self else { return }
            
            guard error == nil else {
                AnalyticsHelper.shared.logEvent(.restorationFailure, properties: [
                    .errorDescription: error?.localizedDescription ?? "--"
                ])
                completionHandler(false, .purchaseFailed)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self._isProUser = true
                AnalyticsHelper.shared.logEvent(.restorationSuccessful)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }

    public func fetchAvailableProducts(for offeringIdentifier: String? = nil, completionHandler: @escaping ProductsCompletionHandler) {
        Purchases.shared.getOfferings { (offerings, error) in
            if let error = error {
                completionHandler(nil, nil, .noProductsAvailable)
                return
            }

            let offering: Offering?
            if let offeringIdentifier = offeringIdentifier {
                offering = offerings?.offering(identifier: offeringIdentifier)
            } else {
                offering = offerings?.current
            }

            guard let currentOffering = offering else {
                completionHandler(nil, nil, .noProductsAvailable)
                return
            }

            let availableProducts = currentOffering.availablePackages.map { IAPProduct(package: $0) }
            completionHandler(currentOffering.identifier, availableProducts, nil)
        }
    }
    
    public func purchasePackage(_ package: IAPProduct, offeringIdentifier: String, _ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.purchase(package: package.package) { [weak self] (transaction, purchaserInfo, error, userCancelled) in
            guard let self = self else { return }
            
            if userCancelled {
                AnalyticsHelper.shared.logEvent(.userCancelledPurchase, properties: [
                    .productId: package.product.productIdentifier
                ])
                completionHandler(!userCancelled, .userCancelledPurchase)
                return
            }
            
            guard error == nil else {
                completionHandler(false, .purchaseFailed)
                return
            }
            
            guard let transaction = transaction else {
                completionHandler(false, nil)
                return
            }
            
            if let entitlement = OfferingIdentifier(rawValue: offeringIdentifier)?.entitlement,
               purchaserInfo?.entitlements[entitlement]?.isActive == true {
                let revenue = AMPRevenue()
                revenue.setProductIdentifier(package.product.productIdentifier)
                revenue.setEventProperties([
                    "Transaction Date": transaction.sk1Transaction?.transactionDate,
                    "Transaction Identifier": transaction.transactionIdentifier
                ])
                AnalyticsHelper.shared.logRevenue(revenue)
                User.shared.saveUserProperty(.dateOfSubscription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
                User.shared.saveUserProperty(.userPlan, value: package.product.productIdentifier)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }

    public func purchaseConsumablePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.purchase(package: package.package) { [weak self] (transaction, purchaserInfo, error, userCancelled) in
            guard let self = self else { return }
            
            if userCancelled {
                AnalyticsHelper.shared.logEvent(.userCancelledPurchase, properties: [.productId: package.product.productIdentifier])
                completionHandler(false, .userCancelledPurchase)
            } else if let error = error {
                completionHandler(false, .purchaseFailed)
                print("Purchase failed with error: \(error.localizedDescription)")
            } else if let transaction = transaction {
                // Purchase was successful, handle further processing here.
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
                print("Unexpected error: No transaction or error received.")
            }
        }
    }
    
    public func purchasePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
        AnalyticsHelper.shared.logEvent(.initiatesPurchase,
                                                 properties: [
                                                    .productId: package.product.productIdentifier,
                                                    .price: package.price
        ])
        
        Purchases.shared.purchase(package: package.package) { (transaction, purchaserInfo, error, userCancelled) in
            if userCancelled {
                AnalyticsHelper.shared.logEvent(.userCancelledPurchase,
                                                         properties: [
                                                            .productId: package.product.productIdentifier
                ])
                completionHandler(!userCancelled, .userCancelledPurchase)
                return
            }
            
            guard error == nil else {
                completionHandler(false, .purchaseFailed)
                return
            }
            
            guard let transaction = transaction else {
                completionHandler(false, nil)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self._isProUser = true
                let revenue = AMPRevenue()
                revenue.setProductIdentifier(package.product.productIdentifier)
                revenue.setEventProperties([
                    "Transaction Date": transaction.sk1Transaction?.transactionDate,
                    "Transaction Identifier": transaction.transactionIdentifier
                ])
                AnalyticsHelper.shared.logRevenue(revenue)
//                AppsFlyerHelper.shared.logRevenue(for: package, transaction: transaction)
                User.shared.saveUserProperty(.dateOfSubscription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
                User.shared.saveUserProperty(.userPlan, value: package.product.productIdentifier)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }

    public func handlePurchaseInfo(_ purchaserInfo: CustomerInfo?, for transaction: StoreTransaction) {
        if purchaserInfo?.entitlements["pro"]?.isActive == true {
            self._isProUser = true
            let revenue = AMPRevenue()
            revenue.setProductIdentifier(purchaserInfo?.entitlements["pro"]?.productIdentifier)
            revenue.setEventProperties([
                "Transaction Date": transaction.sk1Transaction?.transactionDate ?? "--",
                "Transaction Identifier": transaction.transactionIdentifier
            ])
            AnalyticsHelper.shared.logRevenue(revenue)
            User.shared.saveUserProperty(.dateOfSubscription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
            if let productIdentifier = purchaserInfo?.entitlements["pro"]?.productIdentifier {
                print("--------Subscription Identifier: \(productIdentifier)")
                User.shared.saveUserProperty(.userPlan, value: productIdentifier)
            }
        }
    }
}
