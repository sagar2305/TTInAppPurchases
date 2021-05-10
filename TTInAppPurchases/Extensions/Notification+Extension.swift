//
//  Notification+Extension.swift
//  CallRecorder
//
//  Created by Sandesh on 17/07/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let accessNumberFetchedNotification = Notification.Name("CallRecorderAccessNumberAreFetchedNotification")
    static let iapProductsFetchedNotification = Notification.Name("CallRecorderIAPProductsFetchedNotification")
    static let requiredPermissionsGrantedNotification = Notification.Name("CallRecorderRequiredPermissionsGrantedNotification")
    static let phoneCallDisconnectedNotification = Notification.Name("CallRecorderPhoneCallDisconnectedNotification")
    static let requestedRecordingsFromWidget = Notification.Name("UserRequestedRecordingsFromWidget")
    static let requestedCallFromWidget = Notification.Name("UserRequestedCallFromWidget")
    static let presentedPlaceACallTab = Notification.Name("PresentedPlaceACallTab")
    static let didFetchedServerFetchDate = Notification.Name("LastFetchedServerDate")
    static let didChangesCLTypingLabelString =  Notification.Name("CLTypingLabelStringChanged")
    static let callsGotUpdatedInBackground = Notification.Name("CallsGotUpdatedInBackground")
}
