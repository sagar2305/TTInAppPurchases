//
//  SKProductExtensions.swift
//  TTInAppPurchases
//
//  Created by Revathi on 20/06/22.
//

import StoreKit
import RevenueCat


extension SubscriptionPeriod.Unit {
    func description(capitalizeFirstLetter: Bool = false, numberOfUnits: Int? = nil) -> String {
        var unitString = String(describing: self)
        
        // Pluralize the unit if the number of units is greater than 1
        if let numberOfUnits = numberOfUnits, numberOfUnits > 1 {
            unitString += "s"
        }

        // Optionally capitalize the first letter
        if capitalizeFirstLetter {
            unitString = unitString.prefix(1).capitalized + unitString.dropFirst()
        }

        // Prepend the number of units, if available
        if let numberOfUnits = numberOfUnits {
            unitString = "\(numberOfUnits) " + unitString
        }
        
        return unitString
    }
}
