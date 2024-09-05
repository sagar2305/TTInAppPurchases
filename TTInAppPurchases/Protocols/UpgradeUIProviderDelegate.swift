//
//  UpgradeUIProviderDelegate.swift
//  TTInAppPurchases
//
//  Created by Sagar Mutha on 8/21/24.
//

import Foundation
import Lottie

public protocol UpgradeUIProviderDelegate: AnyObject {
    func productsFetched() -> Bool
    func headerMessage(for index: Int) -> String
    func subscriptionTitle(for index: Int) -> String
    func subscriptionPrice(for index: Int, withDurationSuffix: Bool) -> String
    func continueButtonTitle(for index: Int) -> String
    func offersFreeTrial(for index: Int) -> Bool
    func introductoryPrice(for index: Int, withDurationSuffix: Bool) -> String?
    func monthlyBreakdownOfPrice(withDurationSuffix: Bool) -> String
    /// provide Lottie animating view for subscription page
    /// and whether to shift the xOffSet (Only For EZTAPE)
    func animatingAnimationView() -> (view: AnimationView,offsetBy: CGFloat?)
    func allFeatures(lifetimeOffer: Bool) -> [String]
    func freeTrialDuration(for index: Int) -> String
    func subscribeButtonSubtitle(for index: Int) -> String
    func subscriptionPricePerMonth(for index: Int) -> Double?
}
