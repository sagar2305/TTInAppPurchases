//
//  User.swift
//  CallRecorder
//
//  Created by Sandesh on 31/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

public struct User {
    
    public static let shared = User()
    
    private init() { }
    
    public var accessNumber: String {
        UserDefaults.standard.string(forKey: Constants.CallRecorderDefaults.selectedAccessNumberKey)
            ?? Constants.CallRecorder.backupAccessNumber.e164String
    }
    
    public func setUserId(_ userId: String) {
        UserDefaults.standard.set(userId, forKey: Constants.CallRecorderDefaults.userId)
    }
    
    public func setDeviceId(_ deviceId: String) {
        UserDefaults.standard.set(deviceId, forKey: Constants.CallRecorderDefaults.deviceId)
    }

    public var phoneNumber: String {
        PhoneNumberHelper.shared.registeredPhoneNumber()?.e164String ?? "--"
    }
    
    public func saveUserProperty(_ property: Constants.AnalyticsUserProperties, value: String) {
        //check if user properties are already stored in user defaults
        DispatchQueue.global().async {
            if var userProperties = UserDefaults.standard.value(forKey: Constants.CallRecorderDefaults.userPropertiesKey) as? [String: Any] {
                userProperties[property.rawValue] = value
                UserDefaults.standard.set(userProperties, forKey: Constants.CallRecorderDefaults.userPropertiesKey)
            } else {
                let userProperty = [property.rawValue: value]
                UserDefaults.standard.set(userProperty, forKey: Constants.CallRecorderDefaults.userPropertiesKey)
            }
            AnalyticsHelper.shared.updateUserProperties()
        }
    }
    
    public func incrementPropertyValue(_ property: Constants.AnalyticsUserProperties) {
        DispatchQueue.global().async {
            if var userProperties = UserDefaults.standard.value(forKey: Constants.CallRecorderDefaults.userPropertiesKey) as? [String: Any],
                var currentValue = userProperties[property.rawValue] as? Int {
                currentValue += 1
                userProperties[property.rawValue] = currentValue
                UserDefaults.standard.set(userProperties, forKey: Constants.CallRecorderDefaults.userPropertiesKey)
            } else {
                let userProperty = [property.rawValue: 1]
                UserDefaults.standard.set(userProperty, forKey: Constants.CallRecorderDefaults.userPropertiesKey)
            }
            AnalyticsHelper.shared.updateUserProperties()
        }
    }
}
