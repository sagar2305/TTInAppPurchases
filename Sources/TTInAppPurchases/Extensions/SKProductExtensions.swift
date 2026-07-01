//
//  SKProductExtensions.swift
//  TTInAppPurchases
//
//  Created by Revathi on 20/06/22.
//

import StoreKit
import RevenueCat


extension RevenueCat.SubscriptionPeriod.Unit {
    /// A human-readable description of the subscription period unit
    /// (e.g. `"day"`, `"3 months"`).
    ///
    /// - Parameters:
    ///   - capitalizeFirstLetter: Capitalizes the first letter of the unit (e.g. `"Month"`).
    ///   - numberOfUnits: When greater than 1, pluralizes the unit and prefixes the count
    ///     (e.g. `2` → `"2 months"`); `nil` or `1` leaves it singular and un-prefixed.
    /// - Returns: The formatted unit string.
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
