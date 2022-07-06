//
//  IAPProduct.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 8/13/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import Purchases

public struct IAPProduct {
    public let   identifier: String
    private let _price: String
    private let _introductoryPrice: String
    public let   product: SKProduct
    public let   offersFreeTrial: Bool
    public let   packageType: Purchases.PackageType
    public let   package: Purchases.Package
    public let freeTrialDuration: String?
    
    private var _durationSuffix: String {
        switch packageType {
        case .annual:
            return " " + "annually".localized
        case .monthly:
            return " " + "monthly".localized
        case .weekly:
            return " " + "weekly".localized
        case .lifetime:
            return "for lifetime".localized
        default:
            return ""
        }
    }
    
    public var displayName: String {
        switch packageType {
        case .annual:
            return "Yearly Premium".localized
        case .monthly:
            return "Monthly Premium".localized
        case .weekly:
            return "Weekly Premium".localized
        case .lifetime:
            return "Lifetime Premium".localized
        default:
            return ""
        }
    }
    
    public var price: String {
        return _price
    }
    
    public var introductoryPrice: String {
        return _introductoryPrice
    }
    
    public var introductoryPriceWithDurationSuffix: String {
        return _introductoryPrice + _durationSuffix
    }
    
    public var priceWithDurationSuffix: String {
        return _price + _durationSuffix
    }
    
    init(package: Purchases.Package) {
        _price = package.localizedPriceString
        _introductoryPrice = package.localizedIntroductoryPriceString
        product = package.product
        packageType = package.packageType
        offersFreeTrial = package.product.introductoryPrice?.paymentMode == .freeTrial
        identifier = package.identifier
        if let period = package.product.introductoryPrice?.subscriptionPeriod {
            freeTrialDuration = period.unit.description(capitalizeFirstLetter: false, numberOfUnits: period.numberOfUnits)
        } else {
            freeTrialDuration = nil
        }
        self.package = package
    }
}
