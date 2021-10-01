//
//  AppControllerTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import XCTest
import MailTMSwift
@testable import TempBox

class AppControllerTests: XCTestCase {
    
    var persistenceManager: TestPersistenceManager!
    var mtDomainService: FakeMTDomainService!
    var mtAccountService: FakeMTAccountService!
    var accountRepo: FakeAccountRepository!
    var accountService: FakeAccountService!
    var sut: AppController!
    
    override func setUp() {
        super.setUp()
        persistenceManager = TestPersistenceManager()
        mtDomainService = FakeMTDomainService()
        mtAccountService = FakeMTAccountService()
        accountRepo = FakeAccountRepository()
        accountService = FakeAccountService()
        sut = AppController(accountService: accountService)
    }
    
    override func tearDown() {
        super.tearDown()
        persistenceManager = nil
        mtDomainService = nil
        mtAccountService = nil
        accountRepo = nil
        accountService = nil
        sut = nil
    }
    
    func getFakeAccount(id: String = "123", address: String = "test@example.com") -> Account {
        let mtAccount = MTAccount(id: id,
                                  address: address,
                                  quotaLimit: 100,
                                  quotaUsed: 0,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: persistenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        return givenAccount
    }
    
    func test_init_whenAccountServiceActiveAccountChanges_changesReflectInLocalProperty() {
        
        let givenAccount = getFakeAccount()
        
        // Initially
        XCTAssertFalse(givenAccount.isArchived)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
        
        // When
        accountService.activeAccounts = [givenAccount]
        
        // Then
        XCTAssertEqual(sut.activeAccounts.count, 1)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
    }
    
    func test_init_whenAccountServiceArchivedAccountChanges_changesReflectInLocalProperty() {
        let givenAccount = getFakeAccount()
        givenAccount.isArchived = true
        
        // Initially
        XCTAssertTrue(givenAccount.isArchived)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
        
        // When
        accountService.archivedAccounts = [givenAccount]
        
        // Then
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        XCTAssertEqual(sut.activeAccounts.count, 0)
    }
    
    func test_archiveAccount_archivesAccountAndUpdatesArchivedAccountProperty() {
        let givenAccount = getFakeAccount()
        givenAccount.isArchived = false
        
        // Initially
        accountService.activeAccounts = [givenAccount]
        XCTAssertFalse(givenAccount.isArchived)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
        XCTAssertEqual(sut.activeAccounts.count, 1)
        
        // When
        sut.archiveAccount(account: givenAccount)
        
        // Then
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        
    }
    
    func test_activateAccount_activatesAccountAndUpdatesActiveAccountProperty() {
        let givenAccount = getFakeAccount()
        givenAccount.isArchived = true
        
        // Initially
        accountService.archivedAccounts = [givenAccount]
        XCTAssertTrue(givenAccount.isArchived)
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        
        // When
        sut.activateAccount(account: givenAccount)
        
        // Then
        XCTAssertEqual(sut.archivedAccounts.count, 0)
        XCTAssertEqual(sut.activeAccounts.count, 1)
        
    }
}
