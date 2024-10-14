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
import PostHog

//import AppsFlyerLib
public class AnalyticsHelper {

    public static let shared = AnalyticsHelper()
    lazy var amplitudeInstance = Amplitude.instance()
    lazy var mixpanelInstance = Mixpanel.mainInstance()
    
    //TODO: - Temporary code to block logging for for document scanner app
    var shouldLogMixPanelEvents: Bool {
        return Bundle.main.bundleIdentifier == "com.triviatribe.callrecorder"
    }

    private init() {
        Amplitude.instance().defaultTracking.sessions = true
        configurePostHog()
    }
    
    // MARK: - Properties
    
    public func createAlias(_ userId: String) {
       
        amplitudeInstance.setUserId(userId, startNewSession: false)
        if !shouldLogMixPanelEvents { return }
        mixpanelInstance.createAlias(userId, distinctId: mixpanelInstance.distinctId)
    }
    
    public func setUserId(_ userId: String) {
        amplitudeInstance.setUserId(userId, startNewSession: false)
        PostHogSDK.shared.identify("\(userId)",
                                   userPropertiesSetOnce: [Constants.PostHog.dateOfFirstLogIn: Date().toISO()])
        if !shouldLogMixPanelEvents { return }
        mixpanelInstance.identify(distinctId: userId)
//        AppsFlyerLib.shared().customerUserID = userId
    }

    // MARK: - Event Logging
    public func logEvent(_ event: String) {
        amplitudeInstance.logEvent(event)
        PostHogSDK.shared.capture(event)
        if !shouldLogMixPanelEvents { return }
        mixpanelInstance.track(event: event)
//        AppsFlyerHelper.shared.logEvent(event: event, properties: nil)
    }
    
    public func logEvent(_ type: Constants.AnalyticsEvent) {
        amplitudeInstance.logEvent(type.rawValue)
        PostHogSDK.shared.capture(type.rawValue)
        if !shouldLogMixPanelEvents { return }
        mixpanelInstance.track(event: type.rawValue)
//        AppsFlyerHelper.shared.logEvent(event: type.rawValue, properties: nil)
    }
    
    public func logEvent(_ type: Constants.AnalyticsEvent, properties: [Constants.AnalyticsEventProperties: Any]) {
        amplitudeInstance.logEvent(type.rawValue, withEventProperties: properties)
        let stringProperties = properties.reduce(into: [String: Any]()) { (result, pair) in
            result[pair.key.rawValue] = pair.value
        }
        PostHogSDK.shared.capture(type.rawValue, properties: stringProperties)
        if !shouldLogMixPanelEvents { return }
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
        amplitudeInstance.logRevenueV2(revenue)
//        mixpanelInstance.people.trackCharge(amount: revenue.price.doubleValue)
    }
    
    public func updateUserProperties() {
        guard let userProperties = UserDefaults.standard.value(forKey: Constants.CallRecorderDefaults.userPropertiesKey) as? [String: Any] else {
            return
        }
        print(userProperties)
        amplitudeInstance.setUserProperties(userProperties)
        if !shouldLogMixPanelEvents { return }
        let mixpanelProperties = userProperties.reduce([:]) { (propertiesSoFar, arg1) -> [String: MixpanelType] in
            let (key, value) = arg1
            var propertiesSoFar = propertiesSoFar
            propertiesSoFar[key] = value as? MixpanelType ?? ""
            return propertiesSoFar
        }
        mixpanelInstance.people.set(properties: mixpanelProperties)
    }
    
    //    MARK: - Configuration
        
        // Sets the PostHog API Key
        private func configurePostHog() {
            let config = PostHogConfig(apiKey: Constants.PostHog.apiKey, host: Constants.PostHog.host)
            config.sessionReplay = true
            config.sessionReplayConfig.maskAllImages = false
            config.sessionReplayConfig.maskAllTextInputs = false
            config.sessionReplayConfig.screenshotMode = true
            config.sessionReplayConfig.debouncerDelay = 1.0
            PostHogSDK.shared.setup(config)
        }
        
        // MARK: Screen Recording
        
        public func startScreenRecordingPostHog() {
            let config = PostHogConfig(apiKey: Constants.PostHog.apiKey, host: Constants.PostHog.host)
            config.captureScreenViews = true
            PostHogSDK.shared.startSession()
        }
        
        public func stopScreenRecordingPostHog(){
            let config = PostHogConfig(apiKey: Constants.PostHog.apiKey, host: Constants.PostHog.host)
            config.captureScreenViews = false
        }
}
