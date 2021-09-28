//
//  FakeAccountRepository.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import MailTMSwift
@testable import TempBox

class FakeAccountRepository: AccountRepositoryProtocol {

    private var accounts: [Account] = []
    
    func setAccounts(accounts: [Account]) {
        self.accounts = accounts
    }
    
    func isAccountExists(id: String) -> Bool {
        accounts.contains {
            $0.id == id
        }
    }
    
    func isAccountExists(forAddress address: String) -> Bool {
        accounts.contains {
            $0.address == address
        }
    }
    
    func getAll() -> [Account] {
        return accounts
    }
    
    func getAllActiveAccounts() -> [Account] {
        accounts.filter {
            !$0.isArchived
        }
    }
    
    func getAllArchivedAccounts() -> [Account] {
        accounts.filter {
            $0.isArchived
        }
    }
    
    func getAccount(fromId accountId: String) -> Account? {
        accounts.first { $0.id == accountId }
    }
    
    func create(account mtAccount: MTAccount, password: String, token: String) -> Account {
        let account = Account(context: TestPersistenceManager().mainContext)
        account.set(from: mtAccount, password: password, token: token)
        accounts.append(account)
        return account
    }
    
    func update(account: Account) {
        accounts = accounts.map {
            if $0.id == account.id {
                return account
            }
            
            return $0
        }
    }
    
    func delete(account: Account) {
        accounts = accounts.filter { $0.id != account.id }
    }
    
    func deleteAll() {
        accounts.removeAll()
    }
    
}
