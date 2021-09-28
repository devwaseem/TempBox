//
//  MockAccountRepository.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 25/09/21.
//

import Foundation
import XCTest
import MailTMSwift
@testable import TempBox

class MockAccountRepository: AccountRepositoryProtocol {
       
    var getAllActiveAccountsCallCount = 0
    var givenGetAllActiveAccountsResult: [Account]!
    func getAllActiveAccounts() -> [Account] {
        getAllActiveAccountsCallCount += 1
        return givenGetAllActiveAccountsResult
    }
    
    var getAllArchivedAccountsCallCount = 0
    var givenGetAllArchivedAccountsResult: [Account]!
    func getAllArchivedAccounts() -> [Account] {
        getAllArchivedAccountsCallCount += 1
        return givenGetAllArchivedAccountsResult
    }
    
    var getAllCallCount = 0
    var givenGetAllResult: [Account]!
    func getAll() -> [Account] {
        getAllCallCount += 1
        return givenGetAllResult
    }
    
    var getAccountCallCount = 0
    var getAccountIdPassed: String?
    var givenGetAccountResult: Account?
    func getAccount(fromId accountId: String) -> Account? {
        getAccountCallCount += 1
        getAccountIdPassed = accountId
        return givenGetAccountResult
    }
    
    var createCallCount = 0
    var createMtAccountPassed: MTAccount?
    var createPasswordPassed: String?
    var createTokenPassed: String?
    var givenCreateResult: Account!
    func create(account mtAccount: MTAccount, password: String, token: String) -> Account {
        createCallCount += 1
        createMtAccountPassed = mtAccount
        createPasswordPassed = password
        createTokenPassed = token
        return givenCreateResult
    }
    
    var updateCallCount = 0
    var updateAccountPassed: Account?
    func update(account: Account) {
        updateCallCount += 1
        updateAccountPassed = account
    }
    
    var deleteCallCount = 0
    var deleteAccountPassed: Account?
    func delete(account: Account) {
        deleteCallCount += 1
        deleteAccountPassed = account
    }
    
    var deleteAllCallCount = 0
    func deleteAll() {
        deleteAllCallCount += 1
    }
    
    var isAccountForIdExistsCallCount = 0
    var isAccountForIdResult: Bool!
    func isAccountExists(id: String) -> Bool {
        isAccountForIdExistsCallCount += 1
        return isAccountForIdResult
    }
    
    var isAccountForAddressExistsCallCount = 0
    var isAccountForAddressResult: Bool!
    func isAccountExists(forAddress address: String) -> Bool {
        isAccountForAddressExistsCallCount += 1
        return isAccountForAddressResult
    }
    
}
