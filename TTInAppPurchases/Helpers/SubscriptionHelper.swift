//
//  SubscriptionHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 7/29/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit
import Purchases
import Amplitude

public class SubscriptionHelper {
    
    public enum InAppPurchaseError: Error {
        case noProductsAvailable
        case purchasedFailed
        case userCancelledPurchase
    }
    
    public static let shared = SubscriptionHelper()
    public typealias CompletionHandler = (_ product: [IAPProduct]?, InAppPurchaseError?) -> Void
    public typealias PurchaseCompletion = (_ success: Bool, InAppPurchaseError?) -> Void
    
    private init() {
        refreshPurchaseInfo()
    }
    
    private(set) public var isProUser: Bool = false
    
    private func _process(purchaserInfo: Purchases.PurchaserInfo?) {
        guard let purchaserInfo = purchaserInfo else {
            return
        }
        
        if purchaserInfo.entitlements.all["pro"]?.isActive == true {
            isProUser = true
        } else {
            isProUser = false
        }
    }
    
    public func refreshPurchaseInfo() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            self._process(purchaserInfo: purchaserInfo)
        }
    }
    
    static public func attributedFeatureText(_ feature: String) -> String {
        return "✓  " + feature
    }

    public func restorePurchases(_ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.restoreTransactions { (purchaserInfo, error) in
            guard error == nil else {
                AnalyticsHelper.shared.logEvent(.restorationFailure,
                                                         properties: [
                                                            .errorDescription: error?.localizedDescription ?? "--"
                ])
                completionHandler(false, .purchasedFailed)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self.isProUser = true
                TTInAppPurchases.AnalyticsHelper.shared.logEvent(.restorationSuccessful)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
//    private public func _offeringIdentifier(for event: EventForSubscription) -> String {
//        switch event {
//        case .playRecording,
//             .transcribeRecording,
//             .shareRecording,
//             .giftOffer:
//            return Constants.Offering.onlyAnnualDiscountedNoTrialRecordingScreen
//        case .onFirstOnBoardingCompletion:
//            return Constants.Offering.onlyAnnualDiscountedNoTrialOnboarding
//        case .call:
//            return Constants.Offering.onlyAnnualDiscountedNoTrialHomeScreen
//        }
//    }
    
    
    public func fetchAvailableProducts(for offeringIdentifier: String? = nil, completionHandler: @escaping CompletionHandler) {
        var availableProducts: [IAPProduct]?
        Purchases.shared.offerings { (offerings, _) in
            if let offerings = offerings {
                
                if offeringIdentifier == nil {
                    // all available packages
                    if let packages = offerings.current?.availablePackages {
                        availableProducts = packages.map { IAPProduct(package: $0) }
                    }
                } else {
                    //
                    if let packages = offerings.offering(identifier: offeringIdentifier)?.availablePackages {
                        availableProducts = packages.map { IAPProduct(package: $0) }
                    }
                }
                
                // completion before notif to pass on the value
                completionHandler(availableProducts, nil)
            } else {
                completionHandler(availableProducts, InAppPurchaseError.noProductsAvailable)
            }
        }
    }
    
    public func purchasePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
        AnalyticsHelper.shared.logEvent(.initiatesPurchase,
                                                 properties: [
                                                    .productId: package.product.productIdentifier,
                                                    .price: package.price
        ])
        
        Purchases.shared.purchasePackage(package.package) { (transaction, purchaserInfo, error, userCancelled) in
            
            if userCancelled {
                AnalyticsHelper.shared.logEvent(.userCancelledPurchase,
                                                         properties: [
                                                            .productId: package.product.productIdentifier
                ])
                completionHandler(!userCancelled, .userCancelledPurchase)
                return
            }
            
            guard error == nil else {
                completionHandler(false, .purchasedFailed)
                return
            }
            
            guard let transaction = transaction else {
                completionHandler(false, nil)
                return
            }
            
            if purchaserInfo?.entitlements["pro"]?.isActive == true {
                self.isProUser = true
                let revenue = AMPRevenue()
                revenue.setProductIdentifier(package.product.productIdentifier)
                revenue.setEventProperties([
                    "Transaction Date": transaction.transactionDate ?? "--",
                    "Transaction Identifier": transaction.transactionIdentifier ?? "--"
                ])
                AnalyticsHelper.shared.logRevenue(revenue)
//                AppsFlyerHelper.shared.logRevenue(for: package, transaction: transaction)
                User.shared.saveUserProperty(.dateOfSubScription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
                User.shared.saveUserProperty(.userPlan, value: package.product.productIdentifier)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
    public func handlePurchaseInfo(_ purchaserInfo: Purchases.PurchaserInfo?, for transaction: SKPaymentTransaction) {
        if purchaserInfo?.entitlements["pro"]?.isActive == true {
            self.isProUser = true
            let revenue = AMPRevenue()
            revenue.setProductIdentifier(purchaserInfo?.entitlements["pro"]?.productIdentifier)
            revenue.setEventProperties([
                "Transaction Date": transaction.transactionDate ?? "--",
                "Transaction Identifier": transaction.transactionIdentifier ?? "--"
            ])
            AnalyticsHelper.shared.logRevenue(revenue)
//                AppsFlyerHelper.shared.logRevenue(for: package, transaction: transaction)
            User.shared.saveUserProperty(.dateOfSubScription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
            if let productIdentifier =  purchaserInfo?.entitlements["pro"]?.productIdentifier {
                print("--------Subscription Identifier: \(productIdentifier)")
                User.shared.saveUserProperty(.userPlan, value: productIdentifier)
            }
        }
    }
}

