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
    private var _lifetimePlan: Bool
    private var _lifetimePlanAllCountries: Bool
    private var _autoCallEnabledForCountryCodes: [Int]
    
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
    
    public var isLifetimePlanAvailable: Bool {
        if SubscriptionHelper.shared.isIndianAppStore() {
            return _lifetimePlan
        } else {
            return _lifetimePlanAllCountries
        }
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
        _lifetimePlan = currentConfiguration?.lifetimePlan ?? false
        _lifetimePlanAllCountries = currentConfiguration?.lifetimePlanAllCountries ?? false
        _autoCallEnabledForCountryCodes = currentConfiguration?.autoCallEnabledForCountryCodes ?? []
    }
    
    public mutating func update(config: Configuration) {
        _minimumAppVersion = config.minimumVersion
        _inReview = config.inReview
        _freeUserRecordingPlaybackDuration = config.freeUserRecordingPlaybackDuration
        _reviewPromptOnStartup = config.reviewPromptOnStartup
        _lifetimePlan = config.lifetimePlan
        _lifetimePlanAllCountries = config.lifetimePlanAllCountries
        _autoCallEnabledForCountryCodes = config.autoCallEnabledForCountryCodes
    }
}
