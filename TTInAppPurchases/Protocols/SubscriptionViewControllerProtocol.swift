//
//  SubscriptionViewControllerProtocol.swift
//  CallRecorder
//
//  Created by Sandesh on 29/10/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit

public protocol SubscriptionViewControllerProtocol: UIViewController {
    var delegate: SubscriptionViewControllerDelegate? { get set }
    var uiProviderDelegate: UpgradeUIProviderDelegate? { get set }
    var giftOffer: Bool { get set }
    var hideCloseButton: Bool { get set }
}
