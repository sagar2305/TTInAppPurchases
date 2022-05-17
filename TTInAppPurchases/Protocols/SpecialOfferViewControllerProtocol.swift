//
//  SpecialOfferViewControllerProtocol.swift
//  CallRecorder
//
//  Created by Sandesh on 03/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit


public protocol SpecialOfferViewControllerProtocol:  UIViewController {
    var delegate: SpecialOfferViewControllerDelegate? { get set}
    var specialOfferUIProviderDelegate: SpecialOfferUIProviderDelegate? { get set }
    func updateTimer(_ timeString: String)
}

