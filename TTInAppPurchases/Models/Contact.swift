//
//  Contact.swift
//  CallRecorder
//
//  Created by Sagar Mutha on 6/12/20.
//  Copyright © 2020 Smart Apps. All rights reserved.
//

import Foundation
import PhoneNumberKit
import Contacts

struct Contact: Codable {
    let phoneNumber: PhoneNumber
    let name: String
    let thumbnail: Data? //image
    
    init(with cnContact: CNContact, number: PhoneNumber) {
        let formatter = CNContactFormatter()
        formatter.style = .fullName
        name = formatter.string(from: cnContact) ?? ""

        phoneNumber = number
        thumbnail = cnContact.thumbnailImageData
    }
    
    var displayImage: UIImage? {
        return thumbnail != nil ? UIImage(data: thumbnail!) : nil
    }
}

extension Contact {
    /// Please supply phoneNumber in .E164 format
    static func cache(contact: Contact, for phoneNumber: String) {
        var contacts: [String: Contact] = [:]
        if let cachedContacts = _cached() {
            contacts = cachedContacts
        }
        
        contacts[phoneNumber] = contact
        UserDefaults.standard.save(contacts, forKey: Constants.CallRecorderDefaults.savedContactsKey)
    }
    
    /// Please supply phoneNumber in .E164 format
    static func cachedContact(for number: String?) -> Contact? {
        guard let number = number, let contacts = _cached() else {
            return nil
        }
        
        return contacts[number]
    }
    
    // MARK: - Private
    private static func _cached() -> [String: Contact]? {
        if let cachedContacts: [String: Contact] =
            UserDefaults.standard.fetch(forKey: Constants.CallRecorderDefaults.savedContactsKey) {
            return cachedContacts
        }
        return nil
    }
}
