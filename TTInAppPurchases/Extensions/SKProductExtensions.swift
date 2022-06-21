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
        let period: String = {
            switch self {
            case .day: return "day".localized
            case .week: return "week".localized
            case .month: return "month".localized
            case .year: return "year".localized
            @unknown default: return "N/A"
            }
        }()
        
        var numUnits = ""
        var plural = ""
        if let numberOfUnits = numberOfUnits {
            numUnits = "\(numberOfUnits) " // Add space for formatting
            plural = numberOfUnits > 1 ? "s" : ""
        }
        return "\(numUnits)\(capitalizeFirstLetter ? period.capitalized : period)\(plural.localized)"
    }
}
