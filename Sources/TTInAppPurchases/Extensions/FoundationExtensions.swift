//
//  FoundationExtensions.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 5/19/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit
import SwiftDate

// Helper extension for rounding to decimal places
public extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

public extension CGFloat {
    func toInt() -> Int {
        return Int(self)
    }
}

public extension Int {
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

public extension Int {
    func toString() -> String {
        return String(self)
    }
    
    var toCommaSeparatedString: String {
        if self == Int.max {
            return "Unlimited".localized
        }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
        return formattedNumber ?? String(self)
    }
}

public extension TimeInterval {
    func clockTime(showHours: Bool = false) -> String {
        let date = DateInRegion(seconds: self)
        if self > 3600 || showHours {
            return date.toFormat("HH:mm:ss")
        } else {
            return date.toFormat("mm:ss")
        }
    }
}

public extension Array where Element: Equatable {
    func findDuplicates() -> [Element] {
        var result = [Element]()
        var duplicates = [Element]()
        
        for value in self {
            if result.contains(value) {
                duplicates.append(value)
            } else {
                result.append(value)
            }
        }

        return duplicates
    }
}

public extension UserDefaults {

    func save<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        let encodedObject = try? encoder.encode(object)
        UserDefaults.standard.set(encodedObject, forKey: key)
    }

    func fetch<T: Codable>(forKey key: String) -> T? {
        if let object = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            }
        }
        return nil
    }
}

public extension NSNumber {
    func toCurrency(locale: Locale?) -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        if locale != nil {
            numberFormatter.locale = locale
        }
        return numberFormatter.string(from: self)
    }
}

public extension Date {
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
}
