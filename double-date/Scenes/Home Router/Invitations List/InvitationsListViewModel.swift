//
//  InvitationsListViewModel.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct InvitationsListViewModel {
    
    let disposeBag = DisposeBag()
    private let invitationService = InvitationService()
    private let _invitations = Variable<[Invitation]>([])
    private let errorTracker = ErrorTracker()
    
    //MARK: - Outputs
    var invitations: Driver<[Invitation]> {
        return _invitations.asDriver()
    }
    
    var error: Driver<NetworkError> {
        return errorTracker.asDriver()
    }
    
    func bindFetchInvites(_ observable: Observable<Void>) {
        observable
            .flatMapLatest {
                self.invitationService.getInvites()
                    .trackNetworkError(self.errorTracker)
                    .asDriverOnErrorJustComplete()
            }
            .bind(to: _invitations)
            .disposed(by: disposeBag)
    }
    
    func bindSelectedInvite(_ observable: Observable<Invitation>) {
        observable
            .flatMapLatest {
                self.invitationService.acceptInvite(id: $0._id)
                    .trackNetworkError(self.errorTracker)
            }
            .subscribe(onNext: { invite in
                if let index = self._invitations.value.index(where: { $0._id == invite._id }) {
                    self._invitations.value.remove(at: index)
                }
            })
            .disposed(by: disposeBag)
    }
    
}
