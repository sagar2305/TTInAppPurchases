//
//  ConfigurationHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 9/8/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

struct ConfigurationHelper {
    static var shared = ConfigurationHelper()
    
    private var _accessNumberVersion: Int
    private var _minimumAppVersion: String
    private var _inReview: Bool
    private var _freeUserRecordingPlaybackDuration: Int
    private var _reviewPromptOnStartup: Bool
    private var _lifetimePlan: Bool
    private var _lifetimePlanAllCountries: Bool
    
    var minimumAppVersion: String {
       return _minimumAppVersion
    }
    
    var inReview: Bool {
        return _inReview
    }
    
    var freeUserRecordingPlaybackDuration: Int {
        return _freeUserRecordingPlaybackDuration
    }
    
    var reviewPromptOnStartup: Bool {
        return _reviewPromptOnStartup
    }
    
    var isLifetimePlanAvailable: Bool {
        if PhoneNumberHelper.shared.isIndianUser {
            return _lifetimePlan
        } else {
            return _lifetimePlanAllCountries
        }
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
    }
    
    mutating func update(config: Configuration) {
        _minimumAppVersion = config.minimumVersion
        _inReview = config.inReview
        _freeUserRecordingPlaybackDuration = config.freeUserRecordingPlaybackDuration
        _reviewPromptOnStartup = config.reviewPromptOnStartup
    }
}
