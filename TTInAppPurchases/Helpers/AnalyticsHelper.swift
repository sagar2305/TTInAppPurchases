//
//  AmplitudeAnalyticsHelper.swift
//  CallRecorder
//
//  Created by Sandesh on 24/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

//https://help.amplitude.com/hc/en-us/articles/115002278527-iOS-SDK-Installation
//https://help.amplitude.com/hc/en-us/articles/115000465251

import UIKit
import CallKit
import PhoneNumberKit
import SwiftDate
import Amplitude
import Mixpanel
//import AppsFlyerLib
public class AnalyticsHelper {

    public static let shared = AnalyticsHelper()
    lazy var amplitudeInstance = Amplitude.instance()
    lazy var mixpanelInstance = Mixpanel.mainInstance()
    
    //TODO: - Temporary code to block logging for for document scanner app
    var shouldLogEvent: Bool {
        return Bundle.main.bundleIdentifier == "com.triviatribe.callrecorder"
    }

    private init() {
        if !shouldLogEvent { return }
        amplitudeInstance.trackingSessionEvents = true
    }
    
    // MARK: - Properties
    
    public func createAlias(_ userId: String) {
        if !shouldLogEvent { return }
        amplitudeInstance.setUserId(userId, startNewSession: false)
        mixpanelInstance.createAlias(userId, distinctId: mixpanelInstance.distinctId)
    }
    
    public func setUserId(_ userId: String) {
        if !shouldLogEvent { return }
        amplitudeInstance.setUserId(userId, startNewSession: false)
        mixpanelInstance.identify(distinctId: userId)
//        AppsFlyerLib.shared().customerUserID = userId
    }

    // MARK: - Event Logging
    public func logEvent(_ event: String) {
        if !shouldLogEvent { return }
        amplitudeInstance.logEvent(event)
        mixpanelInstance.track(event: event)
//        AppsFlyerHelper.shared.logEvent(event: event, properties: nil)
    }
    
    public func logEvent(_ type: Constants.AnalyticsEvent) {
        if !shouldLogEvent { return }
        amplitudeInstance.logEvent(type.rawValue)
        mixpanelInstance.track(event: type.rawValue)
//        AppsFlyerHelper.shared.logEvent(event: type.rawValue, properties: nil)
    }
    
    public func logEvent(_ type: Constants.AnalyticsEvent, properties: [Constants.AnalyticsEventProperties: Any]) {
        if !shouldLogEvent { return }
        amplitudeInstance.logEvent(type.rawValue, withEventProperties: properties)
        let mixpanelProperties = properties.reduce([:]) { (propertiesSoFar, arg1) -> [String: MixpanelType] in
            let (key, value) = arg1
            var propertiesSoFar = propertiesSoFar
            propertiesSoFar[key.rawValue] = value as? MixpanelType ?? ""
            return propertiesSoFar
        }
        mixpanelInstance.track(event: type.rawValue, properties: mixpanelProperties)
//        AppsFlyerHelper.shared.logEvent(event: type.rawValue, properties: properties)
        
    }
    
    public func logRevenue(_ revenue: AMPRevenue) {
        if !shouldLogEvent { return }
        amplitudeInstance.logRevenueV2(revenue)
//        mixpanelInstance.people.trackCharge(amount: revenue.price.doubleValue)
    }
    
    public func updateUserProperties() {
        if !shouldLogEvent { return }
        guard let userProperties = UserDefaults.standard.value(forKey: Constants.CallRecorderDefaults.userPropertiesKey) as? [String: Any] else {
            return
        }
        print(userProperties)
        amplitudeInstance.setUserProperties(userProperties)
        let mixpanelProperties = userProperties.reduce([:]) { (propertiesSoFar, arg1) -> [String: MixpanelType] in
            let (key, value) = arg1
            var propertiesSoFar = propertiesSoFar
            propertiesSoFar[key] = value as? MixpanelType ?? ""
            return propertiesSoFar
        }
        mixpanelInstance.people.set(properties: mixpanelProperties)
    }
}
