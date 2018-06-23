//
//  ContactsStore.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import Contacts
import RxSwift

struct ContactsStore {
    
    private let store = CNContactStore()
    
    func isAuthorized() -> Observable<Bool> {
        return Observable.create { (observer) -> Disposable in
            if CNContactStore.authorizationStatus(for: .contacts) != .authorized {
                observer.onNext(false)
                observer.onCompleted()
            } else {
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func requestAccess() -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            self.store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                if authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                }
                
                if let error = error {
                    observer.onError(error)
                }
            })
            return Disposables.create()
        }
    }
    
    func userContacts() -> Observable<[Contact]> {
        return Observable.create { observer in
            let contacts = self.fetchContacts()
            observer.onNext(contacts)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    private func fetchContacts() -> [Contact] {
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactThumbnailImageDataKey,
                           CNContactImageDataAvailableKey,
                           CNContactPhoneNumbersKey, CNContactEmailAddressesKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        var contacts = [Contact]()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: {
                (cnContact, stop) -> Void in
                var primaryNumber: String?
                var mobileNumber: String?
                var allNumbers: [String] = []
                cnContact.phoneNumbers.forEach {
                    if $0.label == CNLabelPhoneNumberMain { primaryNumber = $0.value.stringValue.digits }
                    if $0.label == CNLabelPhoneNumberMobile { mobileNumber = $0.value.stringValue.digits }
                    allNumbers.append($0.value.stringValue.digits)
                }
                print("\(cnContact.familyName): \(allNumbers.first ?? "No number")")
                let contact = Contact(id: UUID().uuidString,
                                      firstName: cnContact.givenName,
                                      lastName: cnContact.familyName,
                                      primaryNumber: primaryNumber ?? mobileNumber,
                                      numbers: allNumbers)
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return contacts
    }
    
}
