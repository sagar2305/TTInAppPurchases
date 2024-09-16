//
//  PhoneContactsHelper.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 6/12/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import Contacts
import PhoneNumberKit
import UIKit

public class PhoneContactsHelper {
    public static var shared = PhoneContactsHelper()
    private var _cacheInProgress = false
    
    public func cacheContacts(for numbers: [PhoneNumber]) {
        DispatchQueue.global().async {
            if self._cacheInProgress {
                return
            }
            self._cacheInProgress = true
            
            let contacts = self._fetchContacts()
            for cnContact in contacts {
                for number in cnContact.phoneNumbers {
                    let numberRetrieved = number.value
                    if let phoneNumber = PhoneNumberHelper.shared.phoneNumber(from: numberRetrieved.stringValue) {
                        if numbers.contains(phoneNumber) {
                            let contact = Contact(with: cnContact, number: phoneNumber)
                            Contact.cache(contact: contact, for: contact.phoneNumber.e164String)
                        }
                    }
                }
            }
            self._cacheInProgress = false
        }
    }
    
    // MARK: - Private
    private func _fetchContacts() -> [CNContact] {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized else {
            return []
        }
    
        var results: [CNContact] = []
        let contactStore = CNContactStore()
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                    CNContactPhoneNumbersKey as CNKeyDescriptor,
                    CNContactThumbnailImageDataKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request) {(contact, _) in
                results.append(contact)
            }
        } catch {
            print("unable to fetch contacts")
        }
        return results
    }
    
    public func saveAccessNumberToContacts() {
        let store = CNContactStore()
        guard CNContactStore.authorizationStatus(for: .contacts) == .authorized else { return }
        
        let existingContact: CNMutableContact?
        let predicate = CNContact.predicateForContacts(matchingName: "EZTape (Don’t forget to Merge!)")
        let keysToFetch = [CNContactGivenNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

        do {
            let nonMutableContact = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            existingContact = nonMutableContact.first?.mutableCopy() as? CNMutableContact
        } catch {
            fatalError("Error fetching EZTape access number contact: \(error.localizedDescription)")
        }
            
        let accessNumber = PhoneNumberHelper.shared.accessNumber
        let saveRequest = CNSaveRequest()
        let newAccessNumber = CNLabeledValue(
            label: CNLabelPhoneNumberiPhone,
            value: CNPhoneNumber(stringValue: accessNumber.e164String))
        
        if existingContact == nil {
            let newContact = CNMutableContact()
            newContact.givenName = "EZTape (Don’t forget to Merge!)"
            newContact.note = "This access number is dialed and merged with the current call in order to record the conversation".localized
            newContact.imageData = UIImage(named: "callrecorder_app_icon")?.pngData()
            newContact.phoneNumbers = [ newAccessNumber ]
            saveRequest.add(newContact, toContainerWithIdentifier: nil)
        } else {
            existingContact!.phoneNumbers = [ newAccessNumber ]
            saveRequest.update(existingContact!)
        }

        do {
            try store.execute(saveRequest)
        } catch {
            print("Saving contact failed, error: \(error)")
            // Handle the error
        }
    }
}
