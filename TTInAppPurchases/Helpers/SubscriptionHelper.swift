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

class SubscriptionHelper {
    
    enum InAppPurchaseError: Error {
        case noProductsAvailable
        case purchasedFailed
        case userCancelledPurchase
    }
    
    enum EventForSubscription {
        case call
        case giftOffer
        case onFirstOnBoardingCompletion
        case playRecording
        case transcribeRecording
        case shareRecording
    }
    
    static let shared = SubscriptionHelper()
    typealias CompletionHandler = (_ product: [IAPProduct]?, InAppPurchaseError?) -> Void
    typealias PurchaseCompletion = (_ success: Bool, InAppPurchaseError?) -> Void
    
    private init() {
        refreshPurchaseInfo()
    }
    
    private(set) var isProUser: Bool = false
    
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
    
    func refreshPurchaseInfo() {
        Purchases.shared.purchaserInfo { (purchaserInfo, _) in
            self._process(purchaserInfo: purchaserInfo)
        }
    }

    func restorePurchases(_ completionHandler: @escaping PurchaseCompletion) {
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
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
    
//    private func _offeringIdentifier(for event: EventForSubscription) -> String {
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
    
    // This is method is called from everywhere else other than onboarding so always show the reduced
    // price offer (gift offer)
    func startSubscribeCoordinator(navigationController: UINavigationController, parentCoordinator: Coordinator, currentEvent: EventForSubscription = .call) {
//        let identifier = _offeringIdentifier(for: currentEvent)
        var identifier: String
        if ConfigurationHelper.shared.isLifetimePlanAvailable {
            identifier = Constants.Offering.lifetime
        } else {
            identifier = Constants.Offering.annualFullPriceAndSpecialOffer
        }
        let subscribeCoordinator = SubscribeCoordinator(navigationController: navigationController, offeringIdentifier: identifier, giftOffer: true)
        subscribeCoordinator.parentCoordinator = parentCoordinator
        subscribeCoordinator.currentEvent = currentEvent
        parentCoordinator.childCoordinators.append(subscribeCoordinator)
        subscribeCoordinator.start()
    }
    
    func fetchAvailableProducts(for offeringIdentifier: String? = nil, completionHandler: @escaping CompletionHandler) {
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
    
    func purchasePackage(_ package: IAPProduct, _ completionHandler: @escaping PurchaseCompletion) {
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
                AppsFlyerHelper.shared.logRevenue(for: package, transaction: transaction)
                User.shared.saveUserProperty(.dateOfSubScription, value: Date().toFormat("yyyy-MM-dd HH:mm"))
                User.shared.saveUserProperty(.userPlan, value: package.product.productIdentifier)
                completionHandler(true, nil)
            } else {
                completionHandler(false, nil)
            }
        }
    }
}
