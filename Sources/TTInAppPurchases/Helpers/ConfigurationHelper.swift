//
//  ConfigurationHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 9/8/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

public struct ConfigurationHelper {
    public static var shared = ConfigurationHelper()
    
    private var _accessNumberVersion: Int
    private var _minimumAppVersion: String
    private var _inReview: Bool
    private var _freeUserRecordingPlaybackDuration: Int
    private var _reviewPromptOnStartup: Bool
    private var _autoCallEnabledForCountryCodes: [Int]
    private var _fiveMinuteOfferCountries: [String] // New private variable

    private var currentCountryCode: String? {
        return SubscriptionHelper.shared.countryCode()
    }

    public var minimumAppVersion: String {
        return _minimumAppVersion
    }
    
    public var inReview: Bool {
        return _inReview
    }
    
    public var freeUserRecordingPlaybackDuration: Int {
        return _freeUserRecordingPlaybackDuration
    }
    
    public var reviewPromptOnStartup: Bool {
        return _reviewPromptOnStartup
    }
    
    public func isFiveMinuteOfferAvailable() -> Bool {
        guard let currentCountryCode = currentCountryCode else {
            return false
        }
        return _fiveMinuteOfferCountries.contains(currentCountryCode)
    }
    
    public var isAutoCallEnabled: Bool {
        guard let registeredCountryCode = PhoneNumberHelper.shared.registeredPhoneNumber()?.countryCode else {
            return false // If there's no registered phone number, auto-call is not enabled
        }
        return _autoCallEnabledForCountryCodes.contains(Int(registeredCountryCode))
    }

    init() {
        let currentConfiguration: Configuration? = UserDefaults.standard.fetch(forKey: Constants.CallRecorderDefaults.currentAppConfiguration)
        _accessNumberVersion = currentConfiguration?.accessNumberVersion ?? 19
        _minimumAppVersion = currentConfiguration?.minimumVersion ?? "1.0.1"
        _inReview = currentConfiguration?.inReview ?? false
        _freeUserRecordingPlaybackDuration = currentConfiguration?.freeUserRecordingPlaybackDuration ?? 15
        _reviewPromptOnStartup = currentConfiguration?.reviewPromptOnStartup ?? true
        _autoCallEnabledForCountryCodes = currentConfiguration?.autoCallEnabledForCountryCodes ?? []
        _fiveMinuteOfferCountries = currentConfiguration?.fiveMinuteOfferCountries ?? [] // Initialize new property
    }
    
    public mutating func update(config: Configuration) {
        _accessNumberVersion = config.accessNumberVersion
        _minimumAppVersion = config.minimumVersion
        _inReview = config.inReview
        _freeUserRecordingPlaybackDuration = config.freeUserRecordingPlaybackDuration
        _reviewPromptOnStartup = config.reviewPromptOnStartup
        _autoCallEnabledForCountryCodes = config.autoCallEnabledForCountryCodes
        _fiveMinuteOfferCountries = config.fiveMinuteOfferCountries // Update new property
    }
}
