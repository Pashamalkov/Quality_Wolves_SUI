//
//  FetchedContacts.swift
//  Kem
//
//  Created by Павел Мальков on 15.04.2023.
//

import Foundation
import Contacts

struct Contact: Hashable {
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]
    var emailAddresses: [String]
}

enum ContactsAccessError: Error {
    case failedToRequestAccess
    case failedToEnumerateContact
    case accessDenied
}

class FetchedContacts: ObservableObject, Identifiable {

    @Published var contacts = [Contact]()

    func fetchContacts(completion: ((Result<[Contact], Error>)->())? = nil) {
        contacts.removeAll()
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                completion?(.failure(ContactsAccessError.failedToRequestAccess))
                return
            }
            if granted {
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            
                            //       DispatchQueue.main.async {
                            self.contacts.append(Contact(firstName: contact.givenName, lastName: contact.familyName, phoneNumbers: contact.phoneNumbers.map { $0.value.stringValue }, emailAddresses: contact.emailAddresses.map { $0.value as String }
                                                        ))
                            //     }
                        })
                        
                        self.contacts.sort(by: { $0.firstName < $1.firstName })
                        completion?(.success(self.contacts))
                    } catch let error {
                        print("Failed to enumerate contact", error)
                        completion?(.failure(ContactsAccessError.failedToEnumerateContact))
                    }
                }
            } else {
                print("access denied")
                completion?(.failure(ContactsAccessError.accessDenied))
            }
        }
    }
}
