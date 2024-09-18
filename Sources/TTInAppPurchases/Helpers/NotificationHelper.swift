//
//  File.swift
//  
//
//  Created by Admin on 17/09/24.
//

import FirebaseMessaging
import UserNotifications
import UIKit
import FirebaseCore

public class NotificationHelper: NSObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public static let shared = NotificationHelper()
    
    private override init() { }
    
    // Function to configure Firebase and request notification permission
    public func configureNotifications(for application: UIApplication) {
        
        // Set FCM delegate
        Messaging.messaging().delegate = self
        
        // Configure UserNotifications
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            guard success else {
                return
            }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    // Handle receiving a new FCM token
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Save token or send it to your backend
        FirestoreHelper.shared.notificationToken = fcmToken ?? ""
        FirestoreHelper.shared.saveNotificationToken()
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
