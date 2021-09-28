//
//  MTAccount+Extensions.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import MailTMSwift

extension MTAccount {
    init(from account: Account) {
        self = MTAccount(id: account.id,
                         address: account.address,
                         quotaLimit: Int(account.quotaLimit),
                         quotaUsed: Int(account.quotaUsed),
                         isDisabled: account.isDisabled,
                         isDeleted: false,
                         createdAt: account.createdAt,
                         updatedAt: account.updatedAt)
    }
}
