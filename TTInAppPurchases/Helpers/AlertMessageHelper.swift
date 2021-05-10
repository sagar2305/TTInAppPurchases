//
//  AlertMessageHelper.swift
//  CallRecorder
//  Created by Sandesh on 17/08/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import UIKit
/// Use this class to extract commao alerts application
struct AlertMessageHelper {
    
    static let shared = AlertMessageHelper()
    private init() { }

    func presentAlert(message: String) {
        UIAlertView(title: "Something went wrong!".localized,
                    description: message,
                    actions: UIAlertView.Action(title: "OK".localized, onSelect: { })
        ).present()
    }
    
    func presentMicrophoneAccessDeniedAlert() {
        UIAlertView(title: "Permission Denied!".localized,
                    description: "Please grant permission to use the microphone".localized,
                    actions: UIAlertView.Action(title: "Cancel".localized, onSelect: {}),
                    UIAlertView.Action(title: "Settings".localized, onSelect: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
        ).present()
    }
    
    func presentInvalidPhoneNumberAlert(_ completion: @escaping () -> Void) {
        UIAlertView(title: "Invalid Number".localized,
                    description: "Please check the number you have entered".localized,
                    actions: UIAlertView.Action(title: "EDIT".localized, onSelect: completion)
        ).present()
    }
    
    func presentFailedToVerifyNumberAtFirebaseEndAlert() {
        UIAlertView(title: "Something went wrong!".localized,
                    description: "Unable to complete the verification, please check your phone number and try again".localized,
                    actions: UIAlertView.Action(title: "OK".localized, onSelect: { })
        ).present()
    }
    
    func presentInvalidOTPAlert(_ completion: @escaping () -> Void) {
        UIAlertView(title: "Invalid code".localized,
                    description: "The verification code you’ve entered is incorrect, please try again".localized,
                    actions: UIAlertView.Action(title: "EDIT".localized, onSelect: completion)
        ).present()
    }
    
    func presentInternetConnectionUnavailableAlert() {
        UIAlertView(title: "No Internet Connection".localized,
                    description: "Please make sure that your connected to a network".localized,
                    actions: UIAlertView.Action(title: "OK".localized.localized, onSelect: { })
        ).present()
    }
    
    func presentProductUnavailableAlert( onRetry: @escaping () -> Void, onCancel: @escaping () -> Void) {
        UIAlertView(title: "Something went wrong!".localized,
                    description: "Unable to initiate your purchases, please try again".localized,
                    actions: UIAlertView.Action(title: "Cancel".localized, onSelect: onCancel),
                    UIAlertView.Action(title: "Retry".localized, onSelect: onRetry)
        ).present()
    }
    
    func presentPurchaseFailedAlert(onRetry: @escaping () -> Void, onCancel: @escaping () -> Void) {
        UIAlertView(title: "Something went wrong!".localized,
                    description: "Unable to complete your purchase, please try again".localized,
                    actions: UIAlertView.Action(title: "Cancel".localized, onSelect: onCancel),
                    UIAlertView.Action(title: "Retry".localized, onSelect: onRetry)
        ).present()
    }
    
    func presentRestorationFailedAlert(onRetry: @escaping () -> Void, onCancel: @escaping () -> Void) {
        UIAlertView(title: "Something went wrong!".localized,
                    description: "Unable to restore your purchase, please try again".localized,
                    actions: UIAlertView.Action(title: "Cancel".localized, onSelect: onCancel),
                    UIAlertView.Action(title: "Retry".localized, onSelect: onRetry)
        ).present()
    }
    
    func presentAlreadyProAlert(_ completion: @escaping () -> Void) {
        UIAlertView(title: "Success".localized,
                    description: "You are already a pro user with access to all the app features".localized,
                    actions: UIAlertView.Action(title: "OK".localized, onSelect: completion)
        ).present()
    }
    
    func presentTrancriptionNotAvailableAlert() {
        UIAlertView(title: "Not Available".localized,
                    description: "Transcription service is not availabel for selected langauage at present, please try after some time".localized,
                    actions: UIAlertView.Action(title: "OK".localized, onSelect: {})
        ).present()
    }
    
    func presentTranscriptionFailedError() {
        UIAlertView(title: "Something went wrong!".localized,
                    description: "Unable to transcribe your audio currently, please try after some time".localized,
                    actions: UIAlertView.Action(title: "OK".localized, onSelect: {})
        ).present()
    }
    
    func presentTranscriptionPermissionDeniedAlert() {
        UIAlertView(title: "Permission Denied!".localized,
                    description: "Please grant permission to transcribe your audio".localized,
                    actions: UIAlertView.Action(title: "Cancel".localized, onSelect: {}),
                    UIAlertView.Action(title: "Settings".localized, onSelect: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
        ).present()
    }
}
