//
//  Configuration.swift
//  CallRecorder
//
//  Created by Sandesh on 10/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    var accessNumberVersion: Int
    var minimumVersion: String
    var inReview: Bool
    var freeUserRecordingPlaybackDuration: Int
    var reviewPromptOnStartup: Bool
    var lifetimePlan: Bool
    var lifetimePlanAllCountries: Bool
}
