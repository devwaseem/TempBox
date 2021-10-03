//
//  AddAccountControllerTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import XCTest
import MailTMSwift
@testable import TempBox

class AddAccountViewControllerTests: XCTestCase {

    var peristenceManager: TestPersistenceManager!
    var mtAccountService: FakeMTAccountService!
    var mtDomainService: FakeMTDomainService!
    var accountRepo: FakeAccountRepository!
    var accountService: AccountService!
    var sut: AddAccountViewController!

    override func setUp() {
        super.setUp()
        peristenceManager = TestPersistenceManager()
        accountRepo = FakeAccountRepository()
        mtDomainService = FakeMTDomainService()
        mtAccountService = FakeMTAccountService()
        accountService = AccountService(persistenceManager: peristenceManager,
                                        repository: accountRepo,
                                        accountService: mtAccountService,
                                        domainService: mtDomainService)
        sut = AddAccountViewController(accountService: accountService)
    }

    override func tearDown() {
        super.tearDown()
        peristenceManager = nil
        accountRepo = nil
        mtDomainService = nil
        mtAccountService = nil
        accountService = nil
        sut = nil
    }

    // MARK: - Helper function
    func getDomain(id: String = UUID().uuidString, domain: String, isActive: Bool, isPrivate: Bool) -> MTDomain {
        MTDomain(id: id, domain: domain, isActive: isActive, isPrivate: isPrivate, createdAt: .init(), updatedAt: .init())
    }

    func getAccount() -> MTAccount {
        MTAccount(id: "1230-123-123",
                  address: "12345@example.com",
                  quotaLimit: 0,
                  quotaUsed: 100,
                  isDisabled: false,
                  isDeleted: false,
                  createdAt: .init(),
                  updatedAt: .init())
    }

    // MARK: - Init tests cases

    func test_init_whenSuccessfullyRetreivedDomain_setsInitialProperties() {
        XCTAssertFalse(sut.isDomainsLoading)
        XCTAssertEqual(sut.availableDomains.count, 1)
        XCTAssertTrue(sut.selectedDomain != "")
    }

    // MARK: - Other tests cases
    
    func test_addressText_whenAddressEntered_convertsToLowerCase() {
        let givenAddress = "123abcDEF"
        
        sut.addressText = givenAddress
        
        XCTAssertEqual(sut.addressText, "123abcdef")
        
    }

    func test_canCreate_whenValidSituation_returnsTrue() {
        // when
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.shouldGenerateRandomPassword = true

        // then
        XCTAssertTrue(sut.canCreate, "isCreateButtonEnabled should be true")
    }

    func test_generateRandomAddress_assignsRandomAddress() {

        XCTAssertEqual(sut.addressText, "")

        // when
        sut.generateRandomAddress()

        // then
        XCTAssertNotEqual(sut.addressText, "")
        XCTAssertEqual(sut.addressText.count, 10)
    }

    func test_isPasswordValid_shouldReturnTrueForValidPassword() {
        // when
        sut.shouldGenerateRandomPassword = false
        sut.passwordText = "123456"

        // then
        XCTAssertTrue(sut.isPasswordValid, "isPassword should be True")
    }

    func test_isPasswordValid_shouldReturnFalseForInValidPassword() {
        // when
        sut.shouldGenerateRandomPassword = false
        sut.passwordText = "12"

        // then
        XCTAssertFalse(sut.isPasswordValid, "isPassword should be False")
    }

    func test_createNewAddress_whenRandomPassword_createsAccountAndClosesWindow() {
        // given
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.shouldGenerateRandomPassword = true

        // when
        XCTAssertTrue(sut.canCreate)
        sut.createNewAddress()

        // then
        XCTAssertFalse(sut.showErrorAlert)
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertFalse(sut.isAddAccountWindowOpen)
    }

    func test_createNewAddress_whenManualPassword_createsAccountAndClosesWindow() {
        // given
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.passwordText = "123456"
        sut.shouldGenerateRandomPassword = false
        
        // when
        XCTAssertTrue(sut.canCreate)
        sut.createNewAddress()

        // then
        XCTAssertFalse(sut.showErrorAlert)
        XCTAssertEqual(sut.errorMessage, "")
        XCTAssertFalse(sut.isAddAccountWindowOpen)
    }
    
    func test_createNewAddress_whenCanCreateIsFalse_doNothing() {
        sut.createNewAddress()
        XCTAssertFalse(sut.canCreate)
    }

    func test_createNewAddress_whenAddressAlreadyExists_setsErrorMessage() {
        // given
        let givenAddressAlreadyExistsMessage = "address: This value is already used."

        sut.isAddAccountWindowOpen = true
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.shouldGenerateRandomPassword = true
        mtAccountService.error = .mtError(givenAddressAlreadyExistsMessage)
        mtAccountService.accounts = [
            getAccount(),
            MTAccount(id: "123",
                      address: "12345@example.com",
                      quotaLimit: 100,
                      quotaUsed: 0,
                      isDisabled: false,
                      isDeleted: false,
                      createdAt: .init(),
                      updatedAt: .init())
        ]
        XCTAssertTrue(sut.canCreate)
        sut.createNewAddress()

        XCTAssertFalse(sut.isCreatingAccount)
        XCTAssertEqual(sut.showErrorAlert, true)
        XCTAssertEqual(sut.errorMessage, "This address already exists! Please choose a different address")
        XCTAssertTrue(sut.isAddAccountWindowOpen, "The window is closed. The window should stay open if an error is occured")
    }

    func test_createNewAddress_whenServerReturnsError_setsErrorMessage() {
        // given
        let givenErrorMessage = "Test Error: Server Error"

        sut.isAddAccountWindowOpen = true
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.shouldGenerateRandomPassword = true
        mtAccountService.error = .mtError(givenErrorMessage)
        mtAccountService.forceError = true
        sut.createNewAddress()

        XCTAssertFalse(sut.isCreatingAccount)
        XCTAssertEqual(sut.showErrorAlert, true)
        XCTAssertEqual(sut.errorMessage, givenErrorMessage)
        XCTAssertTrue(sut.isAddAccountWindowOpen, "The window is closed. The window should stay open if an error is occured")
    }

    func test_createNewAddress_whenNetworkOrOtherError_setsCustomErrorMessage() {
        let givenErrorMessage = "Test Error: Server Error"

        sut.isAddAccountWindowOpen = true
        sut.selectedDomain = "example.com"
        sut.addressText = "12345"
        sut.shouldGenerateRandomPassword = true
        mtAccountService.error = .networkError(givenErrorMessage)
        mtAccountService.forceError = true
        
        sut.createNewAddress()

        XCTAssertFalse(sut.isCreatingAccount)
        XCTAssertEqual(sut.showErrorAlert, true)
        XCTAssertEqual(sut.errorMessage, "Something went wrong while creating a new address")
        XCTAssertTrue(sut.isAddAccountWindowOpen, "The window is closed. The window should stay open if an error is occured")
    }
}
