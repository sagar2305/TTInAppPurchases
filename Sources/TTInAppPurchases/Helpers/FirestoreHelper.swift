//
//  FirestoreHelper.swift
//  
//
//  Created by Ashok on 18/09/24.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Foundation

public class FirestoreHelper {
    
    public static let shared = FirestoreHelper()
    
    public var notificationToken: String = ""
    public var isAppOpenedFromNotification = false
    public var notificationType: String = ""
    private let database = Firestore.firestore()
    
    public func savePhoneNumberAndNotificationToken(completion: ((Error?) -> Void)? = nil) {
        guard let currentUser = Auth.auth().currentUser else {
            completion?(NSError(domain: "FirestoreHelper", code: 1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user found"]))
            return
        }
        
        let userId = currentUser.uid
        let phoneNumber = currentUser.phoneNumber ?? "" // mean user has not provided any number
        
        database.collection(Constants.FirebaseConstants.userdata).document(userId).setData([Constants.FirebaseConstants.notificationToken: notificationToken, Constants.FirebaseConstants.appUserId: phoneNumber], merge: true) { error in
            completion?(error)
        }
    }
    
    
}

