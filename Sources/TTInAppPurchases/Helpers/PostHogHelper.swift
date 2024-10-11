//
//  PostHogHelper.swift
//  TTInAppPurchases
//
//  Created by Ashok on 10/10/24.
//

import UIKit
import CallKit
import PhoneNumberKit
import SwiftDate
import PostHog

public class PostHogHelper {

    // Singleton instance of PostHogHelper for global access
    public static let shared = PostHogHelper()

    // Private initializer to set up PostHog configuration upon initialization
    private init() {
        let config = PostHogConfig(apiKey: Constants.PostHog.apiKey, host: Constants.PostHog.host)
        config.sessionReplay = true
        config.sessionReplayConfig.maskAllImages = false
        config.sessionReplayConfig.maskAllTextInputs = false
        config.sessionReplayConfig.screenshotMode = true
        config.sessionReplayConfig.debouncerDelay = 1.0
//        Uncomment to capture screen views automatically
//        config.captureScreenViews = true
        PostHogSDK.shared.setup(config)
    }
    
    // MARK: - User Identification
    
    // Sets the user ID for the session
    public func setUserId(_ userId: String) {
        PostHogSDK.shared.identify("\(userId)",
                                   userPropertiesSetOnce: [Constants.PostHog.dateOfFirstLogIn: Date().toISO()])
    }

    // MARK: - Event Logging
    
    // Logs an event with a simple string identifier
    public func logEvent(_ event: String) {
        PostHogSDK.shared.capture(event)
    }
    
    // Logs an event using a predefined event type
    public func logEvent(_ type: Constants.AnalyticsEvent) {
        PostHogSDK.shared.capture(type.rawValue)
    }
    
    // Logs an event with additional properties as a dictionary
    public func logEvent(_ type: Constants.AnalyticsEvent, properties: [Constants.AnalyticsEventProperties: Any]) {
        let stringProperties = properties.reduce(into: [String: Any]()) { (result, pair) in
            result[pair.key.rawValue] = pair.value
        }
        PostHogSDK.shared.capture(type.rawValue, properties: stringProperties)
    }
    
    // MARK: Screen Recording
    
    public func startScreenRecording(screenName: String) {
        PostHogSDK.shared.screen(screenName)
    }

}


