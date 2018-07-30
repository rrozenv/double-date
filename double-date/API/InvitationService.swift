//
//  InvitationService.swift
//  double-date
//
//  Created by Robert Rozenvasser on 7/15/18.
//  Copyright © 2018 Cluk Labs. All rights reserved.
//

import Foundation
import RxSwift

struct InvitationService {
    
    private let network = Network<Invitation>(Secrets.baseURL)
    private let token = MyKeychain.shared.getStringFor(Secrets.tokenKeyString)
    
    func getInvites() -> Observable<[Invitation]> {
        return network.getItems("invitations",
                                headers: [Secrets.tokenKeyString: token ?? ""])
    }
    
    func acceptInvite(id: String) -> Observable<Invitation> {
        return network.updateItem("invitations", itemId: "\(id)/accept")
    }
    
    func rejectInvite(id: String) -> Observable<Invitation> {
        return network.updateItem("invitations", itemId: "\(id)/reject")
    }
    
}
