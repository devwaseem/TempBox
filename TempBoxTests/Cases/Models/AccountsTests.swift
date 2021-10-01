//
//  AccountsTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 01/10/21.
//

import Foundation
import MailTMSwift
import XCTest
@testable import TempBox

class AccountsTests: XCTestCase {
    
    var persistenceManager: TestPersistenceManager!
    var createdDate: Date!
    var updatedDate: Date!
    
    override func setUp() {
        super.setUp()
        persistenceManager = TestPersistenceManager()
        createdDate = Date()
        updatedDate = Date()
    }
    
    override func tearDown() {
        super.tearDown()
        persistenceManager = nil
        createdDate = nil
        updatedDate = nil
    }
    
    func getAccount() -> MTAccount {
        MTAccount(id: "testid",
                  address: "testaddress",
                  quotaLimit: 100,
                  quotaUsed: 10,
                  isDisabled: false,
                  isDeleted: true,
                  createdAt: createdDate,
                  updatedAt: updatedDate
        )
    }
    
    func assertCommonValues(sut: Account) {
        XCTAssertEqual(sut.id, "testid")
        XCTAssertEqual(sut.address, "testaddress")
        XCTAssertEqual(sut.quotaLimit, 100)
        XCTAssertEqual(sut.quotaUsed, 10)
        XCTAssertFalse(sut.isDisabled)
        XCTAssertFalse(sut.isDeleted)
        XCTAssertEqual(sut.createdAt, createdDate)
        XCTAssertEqual(sut.updatedAt, updatedDate)
        XCTAssertEqual(sut.password, "test-password")
        XCTAssertEqual(sut.token, "test-token")
    }
    
    func test_set_whenValuesPassedwithoutIsArchived_setsAccountWithActiveStatus() {
        
        let givenAccount = getAccount()
        
        let sut = Account(context: persistenceManager.mainContext)
        
        // when
        sut.set(from: givenAccount, password: "test-password", token: "test-token")
        
        // then
        
        XCTAssertFalse(sut.isArchived)
        
        assertCommonValues(sut: sut)
    }
    
    func test_set_whenValuesPassedwithIsArchived_setsAccountWithArchivedStatus() {
        
        let givenAccount = getAccount()
        
        let sut = Account(context: persistenceManager.mainContext)
        
        // when
        sut.set(from: givenAccount, password: "test-password", token: "test-token", isArchived: true)
        
        // then
        
        XCTAssertTrue(sut.isArchived)
        
        assertCommonValues(sut: sut)
    }

}
