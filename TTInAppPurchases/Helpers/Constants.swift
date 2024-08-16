//
//  Constants.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 5/30/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

public struct Constants {
    public struct RevenueCat {
        public static let apiKey = "MoLhuBBtzrRhsnUcqvRjHffckdYwfUEX"
    }
    
    public struct Qonversion {
        public static let apiKey = "w0vcdbHWssRpyzklG24RvbAR3t9fDYXz"
    }
    
    public struct Amplitude {
        public static let liveAPIKey = "756fb5f2409d9c0f25de90811a097850"
        public static let devAPIKey = "16c6f8537a7da60e7ce27e6dc42defa3"
    }
    
    public struct Mixpanel {
        public static let liveAPIKey = "a183c69686c8434ed5adc954f7e74710"
        public static let devAPIKey = "c83bcb489dd8bb1fc7466a3ff1d7c1bb"
    }
    
    public struct AppsFlyer {
        public static let sdkKey = "GfL9ihNS8aC3vVjv4QgaK6"
    }
    
    public struct Offering {
//        public static let onlyAnnualDiscountedNoTrialOnboarding = "onlyannualdiscounted_notrial_onboarding"
//        public static let onlyAnnualDiscountedNoTrialHomeScreen = "onlyannualdiscounted_notrial_homescreen"
//        public static let onlyAnnualDiscountedNoTrialRecordingScreen = "onlyannualdiscounted_notrial_recordingscreen"
//        public static let weeklyAndAnnualReduced = "weeklyandannualreduced"
//        public static let annualReducedSpecialOffer = "annualreduced"
        public static let onlyAnnual = "onlyannual"
        public static let lifetime = "lifetime"
        public static let weeklyMonthlyAndAnnual = "weeklymonthlyandannual"
    }
    
    public struct CallRecorder {
        public static let shakeDuration: CFTimeInterval = 0.5
        public static let backupAccessNumber = PhoneNumberHelper.shared.phoneNumber(from: "+12138554064")!
        public static let appUrl = "http://itunes.apple.com/app/id1512476140"
    }
    
    public struct FirebaseConstants {
        public static let hasUserMadeFirstFreeCall = "hasUserMadeFirstFreeCall"
        public static let callCountInTrialPeriod = "CallCountInTrailPeriod"
    }
    
    public struct CallRecorderDefaults {
        public static let userId = "UserID"
        public static let deviceId = "DeviceID"
        public static let isUserOnBoarded = "IsUserOnBoardedd"
        public static let hasUserUsedInteractiveGuide = "HasUserUsedIntractiveGuide"
        public static let sectionsKey = "CallRecorderSectionsKey"
        public static let recentContactsListKey = "RecentContactssListKey"
        public static let recordingsFetchedDateKey = "CallRecorderRecordingsFetchedDateKey"
        public static let savedContactsKey = "CallRecorderSavedContactsKey"
        public static let verifiedNumberKey = "CallRecorderVerifiedNumberKey"
        public static let cachedAccessNumberKey = "CallRecorderCachedAccessNumberKey"
        public static let selectedAccessNumberKey = "CallRecorderAccessNumberKey"
        public static let timeWhenFirstSubscriptionScreenShownKey = "SubscriptionScreenFirstDisplayKey"
        public static let firstTimeUserShownHomeScreen = "firstTimeUserShownHomeScreen"
        public static let lastReviewRequestDate = "lastReviewRequestDate"
        public static let currentAppConfiguration = "CurrentAPPConfiguration"
        public static let userPropertiesKey = "UserPropertyKey"
        public static let haveUserPlayedFirstRecordingKey = "UserPlayedFirstRecording"
        public static let transcriptionLanguageKey = "TranscriptionLanguageKey"
        public static let haveUserGuidedForCallMergeKey = "UserBeenGuidedForCallMergeKey"
        public static let widgetURLKey = "URLPassedFromWidgetKey"
        public static let appOpenedCountKey = "AppOpnedCountKey"
        public static let lastFetchedFreeCallStatusKey = "LastFetchedFreeCallStatus"
        public static let callIDOfCallsUploadedToiCloudKey = "CallIDOfCallsUploadedToiCloud"
        public static let lastFetchDateBackupStatusKey = "LastFetchDateBackupStatus"
        public static let callIdMarkedForDeletionKey = "CallIDMarkedForDeletionFromICloud"
        public static let lastFetchedDateiCloudRecordIDKey = "LastFetchedDateiCloudRecordID"
        public static let subscribedToCallRecordChangesKey = "subscribedToCallRecordChangesKey"
        public static let subscribedToServerFetchDateRecordChangesKey = "SubscribedToServerFetchDateRecordChangesKey"
        public static let deleteAnimationShownStatus = "deleteAnimationShownStatus"
        public static let homeScreenGiftOfferTapped = "homeScreenGiftOfferTapped"
    }
    
    public struct SettingsDefaults {
        public static let isAppLaunch = "IsApplicationLaunch"
        public static let feedbackEmail = "support@eztape.app"
    }
    
    public struct API {
        public static let version = "v1"
        private static let _baseUrl = "https://api.eztape.app/" + version
        
        public static let getAccessNumbers = _baseUrl + "/lists/accessnumbers"
        public static let getRecordings = _baseUrl + "/lists/recordings"
        public static let configurationAPI = _baseUrl + "/lists/appconfig"
    }
    
    public struct WebURL {
        public static let callRecordingLaws = "https://en.wikipedia.org/wiki/Telephone_call_recording_laws"
        public static let termsOfLaw = "https://eztape.app/terms-and-conditions.html"
        public static let privacyPolicy = "https://eztape.app/privacy-policy.html"
    }
    
    public enum Fonts: String {
        case sofiaProLight = "SofiaProLight"
        case sofiaProExtralight = "SofiaProExtraLight"
        case sofiaProMedium = "SofiaProMedium"
        case sofiaProSemibold = "SofiaProSemiBold"
        case sofiaProBold = "SofiaProBold"
        case sofiaProRegular = "SofiaProRegular"
        case sofiaProUltraLight = "SofiaProUltraLight"
        case sofiaProBlack = "SofiaProBlack"
    }
        
    ///Properties that are tied to user and are stored with every single event depicting the state of the use
    public enum  AnalyticsUserProperties: String, CustomStringConvertible {
        
        public var description: String {
            return self.rawValue
        }
        
        case appInstallationDate = "Installation Date"
        case userId = "User Id"
        case registrationDate = "Registration Date"
        case phoneNumber = "Phone Number"
        case accessNumber = "Access Number"
        case userPlan = "User Plan"
        case dateOfSubScription = "Date Of Subscription"
        case outboundCallCount = "Outbound Calls Count"
        case inboundCallCount = "Inbound Calls Count"
        case totalRecordings = "Total Recordings"
        case guideVisitCount = "Guide Visit Count"
        case apiVersion = "Api Version"
        case appVersion = "App Version"
    }
    
    public enum AnalyticsEvent: String, CustomStringConvertible {
        
        public var description: String {
            return self.rawValue
        }
        
        //Onboarding and registration
        case skipOnboarding = "Onboarding - Skipped How-to flow"
        case internetRequiredScreen = "Viewed Internet Required Screen"
        case outgoingCallHowtoScreen = "Viewed Outgoing Calls How-to Screen"
        case incomingCallHowtoScreen = "Viewed Incoming Calls How-to Screen"
        case registrationRequest = "Registration - request"
        case resendOTPRequest = "Registration - OTP Resend Request"
        case otpVerificationRequest = "Registration - OTP Verification Request"
        case registrationSuccess = "Registration - Success"
        case registrationFailed = "Registration - Failure"
        case staticOnboardingScreenContinued = "Initial static onboarding screen"
        case homeScreenDidShow = "Home Screen DidShow"
        case giftOfferDidShow = "Gift Offer DidShow"
        case didClickGiftOffer = "Did Click Gift Offer"
        case specialOfferScreenDidShow = "Entered Special Offer screen"
        case specialOfferCancelled = "Left Special Offer screen"
        
        //Inbound Call
        case callToAccessNumber = "Inbound Call - Dail Access Number"
        
        //Outbound Call
        case dailPadSelection
        case deviceContacteSelection
        
        case initiateOutgoingCall = "Outbound Call - Initiated" //by user
        case outgoingCallStarted = "Outbound Call - Started" //from Plivo End Point
        case outgoingCallConnected = "Outbound Call - Connected" //receiver phone rings
        case outGoingCallInvalid  = "Outbound Call - Invalid" //call is made to invalid number
        case outgoingCallRejected  = "Outbound Call - Rejected" //receiver rejects call
        case outgoingCallReceived = "Outbound Call - Received" //receiver accepts the call
        case outgoingCallHangup = "Outbound Call - Hangup" // receiver hangs up the call
        case outgoingCallEnded = "Outbound Call - Ended" // user ends call
        
        //Subscription Module
        case presentedSubscriptionScreen = "Subscription - Visited Subscription Screen"
        case cancelledSubscriptionScreen = "Subscription - Cancelled Subscription Screen"
        case presentedOfferScreen = "Subscription - Presented Offer Screen"
        case cancelledOfferScreen = "Subscription - Cancelled Offer Screen"
        case initiatesPurchase = "Subscription - Purchase Initiation"
        case restoredPurchase = "Subscription - Restore Purchases"
        case restorationSuccessful = "Subscription - Purchase Restoration Successful"
        case restorationFailure = "Subscription - Purchase Restoration Failed"
        case purchaseFailure = "Subscription - Purchase Failed"
        case userCancelledPurchase = "Subscription - Cancelled Purchases"
        case purchaseComplete = "Subscription - Purchase Complete"
        
        //Settings Module
        case accessNumberChanged = "Access Number Changed"
        
        case sharedRecording = "Recording Shared"
        case userTappedPlayButton = "User Played Recording"
        case userTappedPauseButton = "User Paused Recording"
        case reviewPromptRequested = "App review prompt requested"
        
        //transcription
        case transcriptionRequest = "Transcription - Transcription Requested"
        case languageSelectedForTranscription = "Transcription - Language Selected"
        case transcriptionResult = "Transcription - Result Status"
        
        //widget usage
        case requestedCallFromWidget = "Widget - Requested Call"
        case requestedRecordingsFromWidget = "Widget - Requested Recording"
        
        //New Subscription Flow (Only yearly Subscription)
        case subscribedBeforeRegistration = "Subscription - First time purchase successful"
        case subscribedAfterFirstCall = "Subscription - One free call"
        case subscribedBeforeFirstCall = "Subscription - Without Using Free Call"
        case subscribedAfterPlaying15SecondsOfRecording = "Subscription - Play 15 sec recording"
        case subscribedOnTranscriptionAttempt = "Subscription - On transcribing"
        case subscribedOnSharingAttempt = "Subscription - Share recording"
        case subscribedFrom24hrGiftOffer = "Subscription - 24 hour gift offer"
        case madeFirstFreeCall = "Made one free call"
        case listenedTo15SecondsRecording = "Play 15s recording"
        
        //Interaction User Guide
        case interactiveGuideStarted  = "InteractiveGuide - Screen Did Show"
        case interactiveGuideEnded = "InteractiveGuide - Guide Closed"
        case incomingCallGuideSelected = "InteractiveGuide - Incoming Call Guide Started"
        case outgoingCallGuideSelected = "InteractiveGuide - Outgoing Call Guide Started"
        
        case incomingReceiveCallScreenPresented = "InteractiveGuide - Incoming - Call Screen Presented"
        case incomingAddCallScreenPresented = "InteractiveGuide - Incoming - Add Call Screen Presented"
        case incomingOpenEZTapeScreenPresented = "InteractiveGuide - Incoming - Open EZTape Screen Presented"
        case incomingAppHomeScreenPresented = "InteractiveGuide - Incoming - App Home Screen Presented"
        case incomingDialAccessNumberScreenPresented = "InteractiveGuide - Incoming - Dial Access Number Screen Presented"
        case incomingMergeCallScreenPresented = "InteractiveGuide - Incoming - Merge Call Screen Presented"
        case incomingRecordingScreenPresented = "InteractiveGuide - Incoming - Call Recording Screen Presented"
        case incomingCallGuideCompleted = "InteractiveGuide - Incoming - Guide Completed"
        
        case outgoingOpenEZTapeScreenPresented = "InteractiveGuide - Outgoing - Open EZTape Screen Presented"
        case outgoingAppHomeScreenPresented = "InteractiveGuide - Outgoing - App Home Screen Presented"
        case outgoingDialAccessScreenPresented = "InteractiveGuide - Outgoing - Dial Access Number Screen Presented"
        case outgoingAddCallScreenPresented = "InteractiveGuide - Outgoing - Add Call Screen Presented"
        case outgoingDialPadScreenPresented = "InteractiveGuide - Outgoing - Dial Pad Screen Presented"
        case outgoingMergeCallScreenPresented = "InteractiveGuide - Outgoing - Merge Call Screen Presented"
        case outgoingRecordingScreenScreenPresented = "InteractiveGuide - Outgoing - Call Recording Screen Presented"
        case outgoingCallGuideCompleted = "InteractiveGuide - Outgoing - Guide Completed"
        
        //iCloud test events
        case iCloudSubscribedToCallRecordChanges = "iCloud - Subscribed To Recording Changes"
        case iCloudSubscribedToLastServerFetchDateChange = "iCloud - Subscribed To Last Server Fetch Date Updates"
        case iCloudRecordSaved = "iCloud - Recording Saved"
        case iCloudCallFetched = "iCloud - Recording Fetched"
        case iCloudLastServerFetchDateFetched = "iCloud - Last Server Fetch Date Fetched"
        case iCloudRecordDeleted = "iCloud - Recording Deleted"
        case iCloudUpdatedLastFetchedDate = "iCloud - Last Server Fetch Date Updated"
        case iCloudReceivedRecordCreationNotification = "iCloud - Received New Record Created Notification "
        case iCloudReceivedRecordDeleteNotification = "iCloud - Received Record Deleted Notification "
        case iCloudReceivedLastServerFetchDateChangeNotification = "iCloud - Received Last Fetch Date Updated Notification"
        
        //Records
        case recordingDeletedLocally = "Recording Deleted Locally"
        case apiCalledForFetchingRecords = "Recordings API Called"
        case responseReceivedFromRecordingsAPI = "Recordings API Responded"
        
    }

    public enum AnalyticsEventProperties: String, CustomStringConvertible {
    
        public var description: String {
            return self.rawValue
        }
        
        //shared
        case region = "Region"
        case accessNumber = "Access Number"
        case errorDescription = "Error Description"
        case url = "URL"
        case uuid = "Session ID"
        
        //for registration
        case phoneNumber = "Phone Number"
        case firebaseVerificationId = "Firebase ID"
        case isNewUser = "Is New User"
        
        //outgoing call
        case callId = "Call ID"
        case plivoCallId = "Plivo Call ID"
        case toNumber = "To Number"
        case fromNumber = "From Number"
        
        //subscription
        case productId = "Product ID"
        case price = "Price"
        
        case previousEvent = "PreviousEvent"
        case oldAccessNumber = "Old Access Number"
        case newAccessNumber = "New Access Number"
      
        //transcription
        case locale = "Language Selected"
        case result = "Result"
        
        //iCloud
        case recordId = "Record Id"
        case lastFetchDate = "Last Fetch Date"
        case recordingReceived = "Recording fetched"
        case autoTriggered = "Auto Triggered"
        
        //recording API
        case dateQueryItem = "Query Date"
        
    }
}

public struct CloudKitConstants {
    public static let containerID = "iCloud.com.triviatribe.callrecorder"
    
    public struct Records {
        public static let call = "Call"
        public static let serverFetchDate = "ServerFetchDate"
    }
    
    public struct CallRecordFields {
        public static let callID = "callID"
        public static let direction = "direction"
        public static let duration = "duration"
        public static let startTime = "startTime"
        public static let endTime = "endTime"
        public static let fromNumber = "fromNumber"
        public static let toNumber = "toNumber"
        public static let provider = "provider"
        public static let recording = "recording"
        public static let recordingURL = "recordingURL"
    }
    
    public struct ServerFetchDateFields {
        public static let date = "date"
    }
}
