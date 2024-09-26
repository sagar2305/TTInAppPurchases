//
//  NotificationHelper.swift
//  
//
//  Created by Ashok on 17/09/24.
//

import FirebaseMessaging
import UserNotifications
import UIKit
import FirebaseCore
import PermissionsKit
import NotificationPermission

public class NotificationHelper: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public static let shared = NotificationHelper()
        
    private override init() { }
    
    // Function to configure Firebase and request notification permission
    public func configureNotifications() {
        
        // Set FCM delegate
        Messaging.messaging().delegate = self
        
        // Configure UserNotifications
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        
    }
    
    // Handle receiving a new FCM token
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Save token or send it to your backend
        FirestoreHelper.shared.notificationToken = fcmToken ?? ""
        FirestoreHelper.shared.savePhoneNumberAndNotificationToken()
    }
    
    public func askNotificationPermission(){
        Permission.notification.request {
            if Permission.notification.authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    // UNUserNotificationCenterDelegate method to detect if app was opened via a notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        FirestoreHelper.shared.isAppOpenedFromNotification = true
        FirestoreHelper.shared.notificationType = userInfo["type"]! as! String
        completionHandler()
    }
}
