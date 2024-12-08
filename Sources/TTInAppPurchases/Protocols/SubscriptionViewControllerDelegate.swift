//
//  SubscriptionViewControllerDelegate.swift
//  CallRecorder
//
//  Created by Sandesh on 29/10/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

public protocol SubscriptionViewControllerDelegate: AnyObject {
    func viewWillAppear(_ controller: SubscriptionViewControllerProtocol)
    func viewDidAppear(_ controller: SubscriptionViewControllerProtocol)
    func openRefundLinkOrChat(_ controller: SubscriptionViewControllerProtocol)
    func exit(_ controller: SubscriptionViewControllerProtocol)
    func selectPlan(at index: Int, controller: SubscriptionViewControllerProtocol)
    func restorePurchases(_ controller: SubscriptionViewControllerProtocol)
    func showPrivacyPolicy(_ controller: SubscriptionViewControllerProtocol)
    func showTermsOfLaw(_ controller: SubscriptionViewControllerProtocol)
}
