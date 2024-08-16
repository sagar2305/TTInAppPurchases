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
    
    private var countryCode: String? {
        if let storefront = SKPaymentQueue.default().storefront {
            let countryCode = storefront.countryCode
            return countryCode
        }
        return nil
    }
    
    public func isIndianAppStore() -> Bool {
        if countryCode == "IND" {
            return true
        }
        return false
    }
 
    private func _process(purchaserInfo: CustomerInfo?) {
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
        Purchases.shared.getCustomerInfo { (purchaserInfo, _) in
            self._process(purchaserInfo: purchaserInfo)
        }
    }
    
    static public func attributedFeatureText(_ feature: String) -> String {
        return "✓  " + feature
    }

    public func restorePurchases(_ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
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
        Purchases.shared.getOfferings { (offerings, _) in
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
    
    /// Second number subscription purchase
    public func purchasePackage(_ package: IAPProduct, offeringIdentifier: String, _ completionHandler: @escaping PurchaseCompletion) {
        
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
                completionHandler(false, .purchasedFailed)
                return
            }
            
            guard let transaction = transaction else {
                completionHandler(false, nil)
                return
            }
            
            if let entitlement = OfferingIdentifier(rawValue: offeringIdentifier)?.entitlement, purchaserInfo?.entitlements[entitlement]?.isActive == true {
                let revenue = AMPRevenue()
                revenue.setProductIdentifier(package.product.productIdentifier)
                revenue.setEventProperties([
                    "Transaction Date": transaction.sk1Transaction?.transactionDate ,
                    "Transaction Identifier": transaction.transactionIdentifier 
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
    
    ///SecondNumberConsumerPackagePurchase
    public func purchaseConsumablePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
        Purchases.shared.purchase(package: package.package) { (transaction, purchaserInfo, error, userCancelled) in
            if userCancelled {
                AnalyticsHelper.shared.logEvent(.userCancelledPurchase, properties: [.productId: package.product.productIdentifier])
                completionHandler(false, .userCancelledPurchase)
            } else if let error = error {
                completionHandler(false, .purchasedFailed)
                print("Purchase failed with error: \(error.localizedDescription)")
            } else if let transaction = transaction {
                // Purchase was successful, you can handle further processing here.
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
                    "Transaction Date": transaction.sk1Transaction?.transactionDate,
                    "Transaction Identifier": transaction.transactionIdentifier
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
    
    public func handlePurchaseInfo(_ purchaserInfo: CustomerInfo?, for transaction: StoreTransaction) {
        if purchaserInfo?.entitlements["pro"]?.isActive == true {
            self.isProUser = true
            let revenue = AMPRevenue()
            revenue.setProductIdentifier(purchaserInfo?.entitlements["pro"]?.productIdentifier)
            revenue.setEventProperties([
                "Transaction Date": transaction.sk1Transaction?.transactionDate ?? "--",
                "Transaction Identifier": transaction.transactionIdentifier
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

