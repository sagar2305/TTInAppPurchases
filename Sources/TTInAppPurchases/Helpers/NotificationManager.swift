//
//  NotificationManager.swift
//
//
//  Created by Ashok on 26/09/24.
//

import Foundation
import PermissionsKit
import NotificationPermission
import UIKit
import UserNotifications // Make sure to import UserNotifications

public class NotificationManager {
    public static let shared = NotificationManager()
    
    // This will ask for notification permission
    public func askNotificationPermission() {
        Permission.notification.request { [weak self] in
            guard Permission.notification.authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                self?.scheduleLocalNotifications()
            }
        }
    }
    
    private func saveFirstHomeScreenLaunchTime() {
        let userDefaults = UserDefaults.standard
        let currentTime = Date()
        userDefaults.set(currentTime, forKey: Constants.CallRecorderDefaults.firstAppLaunchTimeKey)
        userDefaults.synchronize()
    }
    
    public func scheduleLocalNotifications() {
        guard Permission.notification.authorized else { return }
        
        let hasUserMadeFirstCall = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.hasUserMadeFirstCall) ?? false
        let hasUserPlayed = UserDefaults.standard.bool(forKey: Constants.CallRecorderDefaults.haveUserPlayedFirstRecordingKey) ?? false
        
        if !hasUserMadeFirstCall || !hasUserPlayed {
            let center = UNUserNotificationCenter.current()
            center.removeAllPendingNotificationRequests()
            saveFirstHomeScreenLaunchTime()
            
            let content = createNotificationContent(callMade: hasUserMadeFirstCall, recordingPlayed: hasUserPlayed)
            
            if let firstLaunchTime = getFirstLaunchTime() {
                scheduleNotification(content: content, firstLaunchTime: firstLaunchTime)
            }
        }
    }
    
    private func createNotificationContent(callMade : Bool, recordingPlayed: Bool) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = !callMade ? Constants.localPushNotificationText.titleForCall : Constants.localPushNotificationText.titleForPlayRecording
        content.body = !callMade ? Constants.localPushNotificationText.subtitleForCall : Constants.localPushNotificationText.subtitleForPlayRecording
        content.sound = UNNotificationSound.default
        return content
    }
    
    
    
    private func getFirstLaunchTime() -> Date? {
        let userDefaults = UserDefaults.standard
        return userDefaults.object(forKey: Constants.CallRecorderDefaults.firstAppLaunchTimeKey) as? Date
    }
    
    private func scheduleNotification(content: UNMutableNotificationContent, firstLaunchTime: Date) {
        let triggerTime = 60 //* 60 * 12 // Example: 12 hours in seconds
        let triggerDate = Date(timeInterval: TimeInterval(triggerTime), since: firstLaunchTime)
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }
}
