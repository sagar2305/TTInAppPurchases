//
//  FiveMinuteOfferViewControllerProtocol.swift
//  CallRecorder
//
//  Created by Sandesh on 03/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit


public protocol FiveMinuteOfferViewControllerProtocol:  UIViewController {
    var delegate: FiveMinuteOfferViewControllerDelegate? { get set}
    var fiveMinOfferUIProviderDelegate: FiveMinuteOfferUIProviderDelegate? { get set }
    func updateTimer(_ timeString: String)
}

