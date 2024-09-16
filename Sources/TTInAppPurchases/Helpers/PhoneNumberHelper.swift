//
//  PhoneNumberHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 6/13/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import PhoneNumberKit

//A PhoneNumberKit instance is relatively expensive to allocate (it parses the metadata and keeps it
//in memory for the object's lifecycle), you should try and make sure PhoneNumberKit is allocated once
//and deallocated when no longer needed.

public struct PhoneNumberHelper {
    public static let shared = PhoneNumberHelper()
    let phoneNumberKit: PhoneNumberKit
    let partialFormatter: PartialFormatter
    
    public var  accessNumber: PhoneNumber {
        UserDefaults.standard.fetch(forKey: Constants.CallRecorderDefaults.selectedAccessNumberKey) ?? Constants.CallRecorder.backupAccessNumber
    }
    
    public var  countryCodeForRegisteredNumber: UInt64 {
        guard let registeredPhoneNumber = registeredPhoneNumber() else {
            return 1
        }
        return registeredPhoneNumber.countryCode
    }
    
    public var  isIndianUser: Bool {
        return countryCodeForRegisteredNumber == 91 ? true : false
    }
    
    public var  tutorialPhoneNumberForUser: String {
        switch countryCodeForRegisteredNumber {
        case 1: return "+12138554022"
        case 33: return "+33186262071"
        case 34: return "+34932204527"
        case 44: return "+447520650302"
        case 52: return "+525541614212"
        case 55: return "+551141302956"
        case 57: return "+5715083347"
        case 91: return "+919582154612"
        case 61: return "+61272018874"
        case 81: return "+815032044321"
        default: return "+12138554022"
        }
    }
    
    /* just for reference do not delete
    US : +1 (213) 855-4022
    France : +33 186 26 5643
    Spain : +34 932 20 4527
    United Kingdom : +44 7520 650302
    Mexico : +52 55 4161 5361
    Brazil : +55 11 4130 - 6452
    Colombia : +57 150 83347
    India : +91 95821 54612
    Australia : +61 2 7201 6648
    49 => Germany
    81 => Japan
    7 => Russia
    39 => Italy
    */
    
    public var  incomingCallerName: String {
        let availableNamesCountryCode: [UInt64] = [1, 33, 34, 49, 81, 7, 91, 39]
        if availableNamesCountryCode.contains(countryCodeForRegisteredNumber) {
            switch countryCodeForRegisteredNumber {
            case 1: return "John Appleseed"
            case 33: return "Clément Guého"
            case 34: return "Pedro Alonso"
            case 49: return "Bjarne Mädel"
            case 81: return "Shota Matsuda"
            case 7: return "Alexander Diachenko"
            case 91: return "Rohit Sharma"
            case 39: return "Franco Nero"
            default: return "John Appleseed"
            }
        } else {
            let currentLanguageCode = Locale.current.languageCode ?? "en"
            switch currentLanguageCode {
            case "fr": return "Clément Guého"
            case "de": return "Bjarne Mädel"
            case "ja": return "Shota Matsuda"
            case "ko": return "Lim Ki-Hong"
            case "ru": return "Alexander Diachenko"
            case "es": return "Pedro Alonso"
            case "en-IN": return "Rohit Sharma"
            case "it": return "Franco Nero"
            default: return "John Appleseed"
            }
        }
    }
    
    private init() {
        phoneNumberKit = PhoneNumberKit()
        partialFormatter = PartialFormatter()
    }
    
    // MARK: - Registered Phone
    
    public func registeredPhoneNumber() -> PhoneNumber? {
//        #if targetEnvironment(simulator)
//        return phoneNumber(from: "+16505551111")
//        #endif
        
        let number: PhoneNumber? = UserDefaults.standard.fetch(forKey: Constants.CallRecorderDefaults.verifiedNumberKey)
        return number
    }
    
    public func setRegisteredPhoneNumber(phoneNumber: PhoneNumber) {
        UserDefaults.standard.save(phoneNumber, forKey: Constants.CallRecorderDefaults.verifiedNumberKey)
    }
    
    public func callerId() -> String {
        var number = registeredPhoneNumber()!.e164String
        number.remove(at: number.startIndex)
        return number
    }
    
    public func phoneNumber(from num: String?) -> PhoneNumber? {
        guard let num = num else {
            return nil
        }
        
        var number: PhoneNumber?
        do {
            number = try phoneNumberKit.parse(num)
        } catch {
//            print("exception while generating number - \(string)")
        }
        return number
    }
    
    public func e164Format(from string: String) -> String? {
        guard let number = phoneNumber(from: string) else {
            return nil
        }
        return e164Format(from: number)
    }
    
    private func _internationalFormat(from string: String) -> String? {
        guard let number = phoneNumber(from: string) else {
            return nil
        }
        return internationalFormat(from: number)
    }
    
    public func e164Format(from number: PhoneNumber) -> String {
        let e164 = phoneNumberKit.format(number, toType: .e164)
        return e164
    }
    
    public func internationalFormat(from number: PhoneNumber) -> String {
        let international = partialFormatter.formatPartial(number.e164String)
        return international
    }
    
    public func countryFlag(from number: PhoneNumber) -> String? {
       return number.regionID? .unicodeScalars
            .map({ 127397 + $0.value })
            .compactMap(UnicodeScalar.init)
            .map(String.init)
            .joined()       
    }
    
    public func countryName(from number: PhoneNumber) -> String? {
        guard let countryCode = number.regionID else { return nil }
        if let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: countryCode) {
            return name
        } else {
            return countryCode
        }
    }
    
    public func filter(_ numbers: [PhoneNumber], for countryCode: UInt64) -> [PhoneNumber] {
        return numbers.filter { phoneNumber in
            return phoneNumber.countryCode == countryCode
        }
    }
    
    public func setAccessNumber(_ number: PhoneNumber) {
        let currentAccessNumber: PhoneNumber?  = UserDefaults.standard.fetch(forKey: Constants.CallRecorderDefaults.selectedAccessNumberKey)
        if currentAccessNumber != nil {
            AnalyticsHelper.shared.logEvent(.accessNumberChanged,
                                                     properties: [
                                                        .oldAccessNumber: currentAccessNumber!.e164String,
                                                        .newAccessNumber: number.e164String
            ])
        }
        
        User.shared.saveUserProperty(.accessNumber, value: number.e164String)
        UserDefaults.standard.save(number, forKey: Constants.CallRecorderDefaults.selectedAccessNumberKey)
        PhoneContactsHelper.shared.saveAccessNumberToContacts()
    }
}
