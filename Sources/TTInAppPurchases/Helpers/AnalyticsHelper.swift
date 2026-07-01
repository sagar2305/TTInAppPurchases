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

    /// Identifies a user who has NOT yet verified a phone number, using a stable
    /// device identifier, so anonymous / onboarding users are trackable in PostHog
    /// (and findable by that ID) instead of only appearing as a random anonymous id.
    ///
    /// Safe to call on every launch: PostHog only links the anonymous session to
    /// `deviceId` the first time; later calls are no-ops. Once the user verifies a
    /// number, call `aliasVerifiedUser(_:)` so the phone identity is merged in.
    public func identifyAnonymousDevice(_ deviceId: String) {
        PostHogSDK.shared.identify(deviceId,
                                   userPropertiesSetOnce: [Constants.PostHog.dateOfFirstLogIn: Date().toISO()])
    }

    /// Links a freshly verified phone-number identity to the current PostHog person.
    ///
    /// `identify()` alone does NOT merge a user who is already identified (e.g. one
    /// identified anonymously via `identifyAnonymousDevice(_:)`), so we alias the
    /// phone number onto the current distinct id first, then run the normal
    /// `setUserId(_:)` to update Amplitude / Mixpanel / PostHog person properties.
    /// Call this once, right after a number is verified — not on every launch.
    public func aliasVerifiedUser(_ userId: String) {
        PostHogSDK.shared.alias(userId)
        setUserId(userId)
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
    
    // MARK: - Breadcrumbs

    /// Logs a lightweight "breadcrumb" to PostHog to build a trail of the user's
    /// actions/screens (visible in the Activity feed and as markers in session replay).
    ///
    /// - Important: Do NOT pass PII (phone numbers, recording URLs) in `message` or
    ///   `properties` — breadcrumbs are visible to the whole team in PostHog. Log
    ///   *what happened*, not *who*. Call only on meaningful transitions, never in loops.
    /// - Note: `"category"` and `"message"` are reserved keys; any same-named entries
    ///   in `properties` are overwritten by the `category`/`message` arguments.
    public func logBreadcrumb(_ message: String,
                              category: String = "navigation",
                              properties: [String: Any] = [:]) {
        PostHogSDK.shared.capture("breadcrumb",
                                  properties: Self.breadcrumbProperties(message,
                                                                        category: category,
                                                                        properties: properties))
    }

    /// Builds the property dictionary sent with a `breadcrumb` event. Pure and
    /// side-effect free so it can be unit-tested without configuring or calling PostHog.
    ///
    /// `"category"` and `"message"` are reserved keys and overwrite any same-named
    /// entries supplied by the caller.
    static func breadcrumbProperties(_ message: String,
                                     category: String,
                                     properties: [String: Any] = [:]) -> [String: Any] {
        var props = properties
        props["category"] = category
        props["message"] = message
        return props
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
