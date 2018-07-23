//
//  SelectContactsViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 6/22/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct ContactViewModel: Queryable {
    let contact: Contact
    var isSelected: Bool
    var uniqueId: String { return contact.id }
    var filterById: String { return "\(contact.firstName) \(contact.lastName)" }
}

protocol SelectContactsViewModelDelegate: BackButtonNavigatable {
    func didSelectContacts(_ contacts: [Contact])
}

struct SelectContactsViewModel {
    
    //MARK: - Properties
    private let contacts = Variable<[ContactViewModel]>([])
    private var contactsAccessAuthorized = Variable(false)
    private let disposeBag = DisposeBag()
    private let contactStore: ContactsStore
    weak var delegate: SelectContactsViewModelDelegate?
    
    init(contactStore: ContactsStore = ContactsStore()) {
        self.contactStore = contactStore
        contactStore.isAuthorized()
            .bind(to: contactsAccessAuthorized)
            .disposed(by: disposeBag)
    }
    
    //MARK: - Outputs
    var hasAccessToContacts: Observable<Bool> {
        return contactsAccessAuthorized.asObservable().share()
    }
    
    var userContacts: Observable<[ContactViewModel]> {
        return contacts.asObservable()
    }
    
    //MARK: - Inputs
    func fetchContacts() {
        self.contactStore.userContacts()
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .map { self.mapContactsToViewModels($0) }
            .bind(to: contacts)
            .disposed(by: disposeBag)
    }
    
    func bindDidSelectEnableContacts(_ observable: Observable<Void>) {
        observable
            .flatMap { self.contactStore.requestAccess() }
            .filter { $0 }
            .do(onNext: { self.contactsAccessAuthorized.value = $0 })
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { _ in self.contactStore.userContacts() }
            .map { self.mapContactsToViewModels($0) }
            .bind(to: contacts)
            .disposed(by: disposeBag)
    }
    
    func bindNextButton(_ observable: Observable<[ContactViewModel]>) {
        observable
            .subscribe(onNext: {
                self.delegate?.didSelectContacts($0.map { $0.contact })
            })
            .disposed(by: disposeBag)
    }
    
    func bindBackButton(_ observable: Observable<Void>) {
        observable
            .subscribe(onNext: { self.delegate?.didTapBackButton() })
            .disposed(by: disposeBag)
    }
    
}

extension SelectContactsViewModel {
    private func mapContactsToViewModels(_ contacts: [Contact]) -> [ContactViewModel] {
        return contacts.map { ContactViewModel(contact: $0, isSelected: false) }
    }
}


