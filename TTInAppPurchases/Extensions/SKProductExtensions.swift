//
//  SKProductExtensions.swift
//  TTInAppPurchases
//
//  Created by Revathi on 20/06/22.
//

import Foundation
import StoreKit

public extension SKProduct.PeriodUnit {
    func description(capitalizeFirstLetter: Bool = false, numberOfUnits: Int? = nil) -> String {
        var period: String = {
            switch self {
            case .day: return "day"
            case .week: return "week"
            case .month: return "month"
            case .year: return "year"
            @unknown default: return "N/A"
            }
        }()
        
        var numUnits = ""
        var plural = ""
        if let numberOfUnits = numberOfUnits {
            numUnits = "\(numberOfUnits) " // Add space for formatting
            plural = numberOfUnits > 1 ? "s" : ""
            period = period + plural
        }
        print("Period: \(period)")
        return "\(numUnits)\(capitalizeFirstLetter ? period.capitalized.localized : period.localized)"
    }
}
