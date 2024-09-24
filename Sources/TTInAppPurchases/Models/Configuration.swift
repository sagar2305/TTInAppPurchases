//
//  Configuration.swift
//  CallRecorder
//
//  Created by Sandesh on 10/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

public struct Configuration: Codable {
    public var accessNumberVersion: Int
    public var minimumVersion: String
    public var inReview: Bool
    public var freeUserRecordingPlaybackDuration: Int
    public var reviewPromptOnStartup: Bool
    public var autoCallEnabledForCountryCodes: [Int] // Changed from boolean to [Int]
    public var fiveMinuteOfferCountries: [String] // New property
}
