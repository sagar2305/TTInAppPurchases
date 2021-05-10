//
//  IAPProduct.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 8/13/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import Purchases

struct IAPProduct {
    let identifier: String
    private let _price: String
    private let _introductoryPrice: String
    let product: SKProduct
    let offersFreeTrial: Bool
    let packageType: Purchases.PackageType
    let package: Purchases.Package
    
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
    
    var displayName: String {
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
    
    var price: String {
        return _price
    }
    
    var introductoryPrice: String {
        return _introductoryPrice
    }
    
    var introductoryPriceWithDurationSuffix: String {
        return _introductoryPrice + _durationSuffix
    }
    
    var priceWithDurationSuffix: String {
        return _price + _durationSuffix
    }
    
    init(package: Purchases.Package) {
        _price = package.localizedPriceString
        _introductoryPrice = package.localizedIntroductoryPriceString
        product = package.product
        packageType = package.packageType
        offersFreeTrial = package.product.introductoryPrice?.paymentMode == .freeTrial
        identifier = package.identifier
        self.package = package
    }
}
