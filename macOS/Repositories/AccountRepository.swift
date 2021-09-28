//
//  AccountRepository.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 17/09/21.
//

import Foundation
import MailTMSwift
import CoreData
import OSLog

protocol AccountRepositoryProtocol {
    
    func isAccountExists(id: String) -> Bool
    func isAccountExists(forAddress address: String) -> Bool
    func getAll() -> [Account]
    func getAllActiveAccounts() -> [Account]
    func getAllArchivedAccounts() -> [Account]
    func getAccount(fromId accountId: String) -> Account?
    @discardableResult func create(account mtAccount: MTAccount, password: String, token: String) -> Account
    func update(account: Account)
    func delete(account: Account)
    func deleteAll()
    
}

final class AccountRepository: AccountRepositoryProtocol {

    private var persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager) {
        self.persistenceManager = persistenceManager
    }

    func getAll() -> [Account] {
        Logger.Repositories.account.info("\(#function) called")
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        let results: [Account]
        do {
            results = try persistenceManager.mainContext.fetch(fetchRequest)
        } catch let error {
            Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
            results = []
        }
        return results
    }
    
    func getAllActiveAccounts() -> [Account] {
        Logger.Repositories.account.info("\(#function) called")
        let predicate = NSPredicate(format: "%K = NO", #keyPath(Account.isArchived))
        return getAllAccounts(withPredicate: predicate)
    }

    func getAllArchivedAccounts() -> [Account] {
        Logger.Repositories.account.info("\(#function) called")
        let predicate = NSPredicate(format: "%K = YES", #keyPath(Account.isArchived))
        return getAllAccounts(withPredicate: predicate)
    }
    
    private func getAllAccounts(withPredicate predicate: NSPredicate) -> [Account] {
        Logger.Repositories.account.info("\(#function) called withPredicate: \(predicate)")
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = predicate
        let results: [Account]
        do {
            results = try persistenceManager.mainContext.fetch(fetchRequest)
        } catch let error {
            Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
            results = []
        }
        return results
    }

    func getAccount(fromId accountId: String) -> Account? {
        Logger.Repositories.account.info("\(#function) called fromId: \(accountId)")
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", accountId)
        var account: Account?
        do {
            let results = try persistenceManager.mainContext.fetch(fetchRequest)
            account = results.first
        } catch let error {
            Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
        }
        return account
    }
    
    func isAccountExists(id: String) -> Bool {
        Logger.Repositories.account.info("\(#function) called id: \(id)")
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        do {
            let resultCount = try persistenceManager.mainContext.count(for: fetchRequest)
            return resultCount > 0
        } catch let error {
            Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
        }
        return false
    }
    
    func isAccountExists(forAddress address: String) -> Bool {
        Logger.Repositories.account.info("\(#function) called forAddress: \(address)")
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(Account.address), address)
        do {
            let resultCount = try persistenceManager.mainContext.count(for: fetchRequest)
            return resultCount > 0
        } catch let error {
            Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
        }
        return false
    }

    @discardableResult
    func create(account mtAccount: MTAccount, password: String, token: String) -> Account {
        Logger.Repositories.account.info("\(#function) called mtAccount: \(mtAccount.address)")
        let context = persistenceManager.mainContext
        let account = Account(context: context)
        context.performAndWait {
            account.set(from: mtAccount, password: password, token: token)
        }
        persistenceManager.saveMainContext()
        return account
    }

    func update(account: Account) {
        Logger.Repositories.account.info("\(#function) called account: \(account)")
        persistenceManager.saveMainContext()
    }

    func delete(account: Account) {
        Logger.Repositories.account.info("\(#function) called account: \(account)")
        persistenceManager.mainContext.performAndWait {
            self.persistenceManager.mainContext.delete(account)
        }
        self.persistenceManager.saveMainContext()
    }

    func deleteAll() {
        Logger.Repositories.account.info("\(#function) called")
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Account.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        let context = persistenceManager.mainContext
        context.performAndWait {
            do {
                try context.executeAndMergeChanges(using: deleteRequest)
            } catch let error {
                Logger.Repositories.account.error("\(#fileID) \(#function) \(#line): \(error.localizedDescription)")
            }
        }
    }

}
