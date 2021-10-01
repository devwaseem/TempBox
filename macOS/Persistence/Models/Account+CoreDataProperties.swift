//
//  Account+CoreDataProperties.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//
//

import Foundation
import CoreData
import MailTMSwift

extension Account {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
        return NSFetchRequest<Account>(entityName: "Account")
    }

    @NSManaged public var id: String
    @NSManaged public var address: String
    @NSManaged public var password: String
    @NSManaged public var quotaLimit: Int32
    @NSManaged public var quotaUsed: Int32
    @NSManaged public var isDisabled: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isArchived: Bool
    @NSManaged public var token: String

    func set(from mtAccount: MTAccount, password: String, token: String, isArchived: Bool = false) {
        self.id = mtAccount.id
        self.address = mtAccount.address
        self.quotaLimit = Int32(mtAccount.quotaLimit)
        self.quotaUsed = Int32(mtAccount.quotaUsed)
        self.isDisabled = mtAccount.isDisabled
        self.createdAt = mtAccount.createdAt
        self.updatedAt = mtAccount.updatedAt
        self.isArchived = isArchived
        self.token = token
        self.password = password
    }
    
}

extension Account: Identifiable {

}
