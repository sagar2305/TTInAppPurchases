//
//  Constants.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 5/30/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation

struct Constants {
    struct RevenueCat {
        static let apiKey = "MoLhuBBtzrRhsnUcqvRjHffckdYwfUEX"
    }
    
    struct Qonversion {
        static let apiKey = "w0vcdbHWssRpyzklG24RvbAR3t9fDYXz"
    }
    
    struct Amplitude {
        static let liveAPIKey = "756fb5f2409d9c0f25de90811a097850"
        static let devAPIKey = "16c6f8537a7da60e7ce27e6dc42defa3"
    }
    
    struct Mixpanel {
        static let liveAPIKey = "a183c69686c8434ed5adc954f7e74710"
        static let devAPIKey = "c83bcb489dd8bb1fc7466a3ff1d7c1bb"
    }
    
    struct AppsFlyer {
        static let sdkKey = "GfL9ihNS8aC3vVjv4QgaK6"
    }
    
    struct Offering {
//        static let onlyAnnualDiscountedNoTrialOnboarding = "onlyannualdiscounted_notrial_onboarding"
//        static let onlyAnnualDiscountedNoTrialHomeScreen = "onlyannualdiscounted_notrial_homescreen"
//        static let onlyAnnualDiscountedNoTrialRecordingScreen = "onlyannualdiscounted_notrial_recordingscreen"
//        static let weeklyAndAnnualReduced = "weeklyandannualreduced"
//        static let annualReducedSpecialOffer = "annualreduced"
        static let annualFullPriceAndSpecialOffer = "annualfullpriceandspecialoffer"
        static let lifetime = "lifetime"
    }
    
    struct CallRecorder {
        static let shakeDuration: CFTimeInterval = 0.5
        static let backupAccessNumber = PhoneNumberHelper.shared.phoneNumber(from: "+12138554064")!
        static let appUrl = "http://itunes.apple.com/app/id1512476140"
    }
    
    struct FirebaseConstants {
        static let hasUserMadeFirstFreeCall = "hasUserMadeFirstFreeCall"
        static let callCountInTrialPeriod = "CallCountInTrailPeriod"
    }
    
    struct CallRecorderDefaults {
        static let userId = "UserID"
        static let deviceId = "DeviceID"
        static let isUserOnBoarded = "IsUserOnBoardedd"
        static let hasUserUsedInteractiveGuide = "HasUserUsedIntractiveGuide"
        static let sectionsKey = "CallRecorderSectionsKey"
        static let recentContactsListKey = "RecentContactssListKey"
        static let recordingsFetchedDateKey = "CallRecorderRecordingsFetchedDateKey"
        static let savedContactsKey = "CallRecorderSavedContactsKey"
        static let verifiedNumberKey = "CallRecorderVerifiedNumberKey"
        static let cachedAccessNumberKey = "CallRecorderCachedAccessNumberKey"
        static let selectedAccessNumberKey = "CallRecorderAccessNumberKey"
        static let timeWhenFirstSubscriptionScreenShownKey = "SubscriptionScreenFirstDisplayKey"
        static let firstTimeUserShownHomeScreen = "firstTimeUserShownHomeScreen"
        static let lastReviewRequestDate = "lastReviewRequestDate"
        static let currentAppConfiguration = "CurrentAPPConfiguration"
        static let userPropertiesKey = "UserPropertyKey"
        static let haveUserPlayedFirstRecordingKey = "UserPlayedFirstRecording"
        static let transcriptionLanguageKey = "TranscriptionLanguageKey"
        static let haveUserGuidedForCallMergeKey = "UserBeenGuidedForCallMergeKey"
        static let widgetURLKey = "URLPassedFromWidgetKey"
        static let appOpenedCountKey = "AppOpnedCountKey"
        static let lastFetchedFreeCallStatusKey = "LastFetchedFreeCallStatus"
        static let callIDOfCallsUploadedToiCloudKey = "CallIDOfCallsUploadedToiCloud"
        static let lastFetchDateBackupStatusKey = "LastFetchDateBackupStatus"
        static let callIdMarkedForDeletionKey = "CallIDMarkedForDeletionFromICloud"
        static let lastFetchedDateiCloudRecordIDKey = "LastFetchedDateiCloudRecordID"
        static let subscribedToCallRecordChangesKey = "subscribedToCallRecordChangesKey"
        static let subscribedToServerFetchDateRecordChangesKey = "SubscribedToServerFetchDateRecordChangesKey"
    }
    
    struct SettingsDefaults {
        static let isAppLaunch = "IsApplicationLaunch"
        static let feedbackEmail = "support@eztape.app"
    }
    
    struct API {
        static let version = "v1"
        private static let _baseUrl = "https://api.eztape.app/" + version
        
        static let getAccessNumbers = _baseUrl + "/lists/accessnumbers"
        static let getRecordings = _baseUrl + "/lists/recordings"
        static let configurationAPI = _baseUrl + "/lists/appconfig"
    }
    
    struct WebURL {
        static let callRecordingLaws = "https://en.wikipedia.org/wiki/Telephone_call_recording_laws"
        static let termsOfLaw = "https://eztape.app/terms-and-conditions.html"
        static let privacyPolicy = "https://eztape.app/privacy-policy.html"
    }
    
    enum Fonts: String {
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
    enum AnalyticsUserProperties: String, CustomStringConvertible {
        
        var description: String {
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
    
    enum AnalyticsEvent: String, CustomStringConvertible {
        
        var description: String {
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

    enum AnalyticsEventProperties: String, CustomStringConvertible {
    
        var description: String {
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

struct CloudKitConstants {
    static let containerID = "iCloud.com.triviatribe.callrecorder"
    
    struct Records {
        static let call = "Call"
        static let serverFetchDate = "ServerFetchDate"
    }
    
    struct CallRecordFields {
        static let callID = "callID"
        static let direction = "direction"
        static let duration = "duration"
        static let startTime = "startTime"
        static let endTime = "endTime"
        static let fromNumber = "fromNumber"
        static let toNumber = "toNumber"
        static let provider = "provider"
        static let recording = "recording"
        static let recordingURL = "recordingURL"
    }
    
    struct ServerFetchDateFields {
        static let date = "date"
    }
}
