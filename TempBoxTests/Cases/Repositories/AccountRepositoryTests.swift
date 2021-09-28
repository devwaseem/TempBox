//
//  AccountRepositoryTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import XCTest
import MailTMSwift
@testable import TempBox

class AccountRepositoryTests: XCTestCase {

    var persistenceManager: PersistenceManager!
    var sut: AccountRepository!

    override func setUp() {
        super.setUp()
        persistenceManager = TestPersistenceManager()
        sut = AccountRepository(persistenceManager: persistenceManager)
    }

    override func tearDown() {
        super.tearDown()
        persistenceManager = nil
        sut = nil
    }

    // MARK: - Helpers

    func getAccount(id: String = UUID().uuidString, address: String = "example.com") -> MTAccount {
        MTAccount(id: id,
                  address: address,
                  quotaLimit: 100,
                  quotaUsed: 10,
                  isDisabled: false,
                  isDeleted: false,
                  createdAt: .init(),
                  updatedAt: .init())
    }

    // MARK: - Given

    func givenAddAccountsToPersistence(mtAccounts: [MTAccount]) {
        for mtAccount in mtAccounts {
            let account = Account(context: persistenceManager.mainContext)
            account.set(from: mtAccount, password: "12345", token: "12345")
        }
        persistenceManager.saveMainContext()
    }

    // MARK: - Test cases

    func test_getAllAccounts_returnsAllAccounts() {
        let givenAccount = getAccount()
        let givenAccounts = [givenAccount]
        givenAddAccountsToPersistence(mtAccounts: givenAccounts)

        let results = sut.getAll()

        XCTAssertEqual(results.count, 1)
    }

    func test_getAccount_whenExistingIdIsPassed_returnsNonNilAccount() throws {
        let givenAccount = getAccount()
        let givenAccounts = [givenAccount]
        givenAddAccountsToPersistence(mtAccounts: givenAccounts)

        let optionalResult = sut.getAccount(fromId: givenAccount.id)
        XCTAssertNotNil(optionalResult)
        let result = try XCTUnwrap(optionalResult)
        XCTAssertEqual(result.id, givenAccount.id)
        XCTAssertEqual(result.address, givenAccount.address)
        XCTAssertEqual(result.createdAt, givenAccount.createdAt)
    }

    func test_getAccount_whenNonExistingIdIsPassed_returnsNilAccount() throws {
        let givenAccount = getAccount()
        let givenAccounts = [givenAccount]
        givenAddAccountsToPersistence(mtAccounts: givenAccounts)

        let optionalResult = sut.getAccount(fromId: givenAccount.id + "~")
        XCTAssertNil(optionalResult)
    }

    func test_create_createsAccountInPersistence() throws {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: persistenceManager.mainContext) { _ in
            return true
        }

        let givenAccount = getAccount()
        sut.create(account: givenAccount, password: "12345", token: "123")

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let optionalSearchedResult = sut.getAccount(fromId: givenAccount.id)
        XCTAssertNotNil(optionalSearchedResult)
        let searchedResult = try XCTUnwrap(optionalSearchedResult)
        XCTAssertEqual(searchedResult.address, givenAccount.address)
    }

    func test_update_updatesAccountInPersistence() throws {

        let givenAccount = getAccount()
        sut.create(account: givenAccount, password: "12345", token:"123") // create the object first

        let searchedResult = sut.getAccount(fromId: givenAccount.id)!

        expectation(forNotification: .NSManagedObjectContextDidSave, object: persistenceManager.mainContext) { _ in
            return true
        }

        searchedResult.address = "update@example.com" // update
        sut.update(account: searchedResult)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let optionalUpdatedSearchedResult = sut.getAccount(fromId: givenAccount.id)
        XCTAssertNotNil(optionalUpdatedSearchedResult)
        let updatedSearchedResult = try XCTUnwrap(optionalUpdatedSearchedResult)
        XCTAssertEqual(updatedSearchedResult.address, "update@example.com")

    }

    func test_delete_deletesTheAccountFromPersistence() {
        let givenDeletingAccount = getAccount(address: "deleting account")
        givenAddAccountsToPersistence(mtAccounts: [
            getAccount(address: "someAccount1@test.com"),
            getAccount(address: "someAccount2@test.com"),
            givenDeletingAccount
        ])

        // get the deletingAccount from persistence
        let deletingAccount = sut.getAccount(fromId: givenDeletingAccount.id)!

        expectation(forNotification: .NSManagedObjectContextDidSave, object: persistenceManager.mainContext) { _ in
            return true
        }

        sut.delete(account: deletingAccount)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let deletedAccount = sut.getAccount(fromId: givenDeletingAccount.id)
        XCTAssertNil(deletedAccount)
    }

    func test_deleteAll_deletesAllAccountFromPersistence() {
        givenAddAccountsToPersistence(mtAccounts: [
            getAccount(address: "someAccount1@test.com"),
            getAccount(address: "someAccount2@test.com"),
            getAccount(address: "someAccount3@test.com"),
            getAccount(address: "someAccount4@test.com")
        ])

        expectation(forNotification: .NSManagedObjectContextDidSave, object: persistenceManager.mainContext) { _ in
            return true
        }

        sut.deleteAll()
        persistenceManager.mainContext.reset() // batch delete wont work inmemory since it works only on the store.

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save did not occur")
        }

        let results = sut.getAll()
        XCTAssertEqual(results.count, 0)
    }

    func test_isAccountExistsForId_whenExists_returnsTrue() {
        let givenAccount = getAccount(address: "someAccount1@test.com")
        givenAddAccountsToPersistence(mtAccounts: [
            givenAccount
        ])
        
        let result = sut.isAccountExists(id: givenAccount.id)
        XCTAssertTrue(result)
    }
    
    func test_isAccountExistsForId_whenDoesNotExists_returnsFalse() {
        let givenAccount = getAccount(address: "someAccount1@test.com")
        givenAddAccountsToPersistence(mtAccounts: [
            givenAccount
        ])
        
        let result = sut.isAccountExists(id: "ID_Does_not_exists")
        XCTAssertFalse(result)
    }
    
    func test_isAccountExistsForAddress_whenExists_returnsTrue() {
        let givenAccount = getAccount(address: "someAccount1@test.com")
        givenAddAccountsToPersistence(mtAccounts: [
            givenAccount
        ])
        
        let result = sut.isAccountExists(forAddress: "someAccount1@test.com")
        XCTAssertTrue(result)
    }
    
    func test_isAccountExistsForAddress_whenDoesNotExists_returnsFalse() {
        let givenAccount = getAccount(address: "someAccount1@test.com")
        givenAddAccountsToPersistence(mtAccounts: [
            givenAccount
        ])
        
        let result = sut.isAccountExists(id: "notExisits@test.com")
        XCTAssertFalse(result)
    }
    
}
