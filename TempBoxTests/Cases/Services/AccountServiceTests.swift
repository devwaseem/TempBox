//
//  AccountServiceTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 25/09/21.
//

import Foundation
import XCTest
import MailTMSwift
import Combine
@testable import TempBox

class AccountServiceTests: XCTestCase {

    var peristenceManager: TestPersistenceManager!
    var mockDomainService: MockMTDomainService!
    var accountService: FakeMTAccountService!
    var accountRepo: AccountRepository!
    var fetchController: NSFetchedResultsController<Account>!
    var sut: AccountService!
    
    var givenDomain: MTDomain!
    var givenDomains: [MTDomain]!
    
    var givenDomainId: String!
    var givenDomainAddress: String!
    
    var subscriptions: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        subscriptions = []
        peristenceManager = TestPersistenceManager()
        accountRepo = AccountRepository(persistenceManager: peristenceManager)
        accountService = FakeMTAccountService()
        mockDomainService = MockMTDomainService()
        
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                     managedObjectContext: peristenceManager.mainContext,
                                                     sectionNameKeyPath: nil,
                                                     cacheName: nil)

        givenDomainId = UUID().uuidString
        givenDomainAddress = "test@example.com"
        givenDomain = MTDomain(id: givenDomainId,
                          domain: givenDomainAddress,
                          isActive: true,
                          isPrivate: false,
                          createdAt: .init(),
                          updatedAt: .init())
        givenDomains = [givenDomain]
    }

    override func tearDown() {
        super.tearDown()
        peristenceManager = nil
        accountRepo = nil
        accountService = nil
        mockDomainService = nil
        sut = nil
        subscriptions = nil
        fetchController = nil
    }
    
    // MARK: - Helpers
    
    func initSut(withSucccessfulDomains domains: [MTDomain], accounts: [Account] = []) {
        mockDomainService.givenGetAllDomainsPubliserResult = .success(domains)
        peristenceManager.saveMainContext()
        sut = AccountService(persistenceManager: peristenceManager,
                             repository: accountRepo,
                             accountService: accountService,
                             domainService: mockDomainService,
                             fetchController: fetchController)
    }
    
    func initSut(withDomainsError domainError: MTError, accounts: [Account] = []) {
        mockDomainService.givenGetAllDomainsPubliserResult = .failure(domainError)
        peristenceManager.saveMainContext()
        sut = AccountService(persistenceManager: peristenceManager,
                             repository: accountRepo,
                             accountService: accountService,
                             domainService: mockDomainService,
                             fetchController: fetchController)
    }
    
    // MARK: - Initializer test cases
    
    func test_init_whenEmptyAccounts_setsInitialProperties() {
        // when
        initSut(withSucccessfulDomains: givenDomains)
        
        // then
        XCTAssertEqual(sut.activeAccounts.count, 0)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
    }
    
    func test_init_whenFailedRetreivingDomains_setsAvailableDomainsAsEmpty() {
        initSut(withDomainsError: .mtError("Test error"))
        
        XCTAssertEqual(sut.availableDomains.count, 0)
    }
    
    func test_init_whenSuccessfullyRetrievedDomains_setsDomains() {
        initSut(withSucccessfulDomains: givenDomains)
        
        XCTAssertEqual(sut.availableDomains.count, givenDomains.count)
        XCTAssertEqual(sut.availableDomains[0].domain, givenDomainAddress)
    }
    
    func test_init_whenActiveAccountsExists_setsActiveAccounts() {
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        XCTAssertEqual(sut.activeAccounts.count, 1)
        XCTAssertEqual(sut.activeAccounts[0].id, "id123")
    }
    
    func test_init_whenArchivedAccountExists_setsArchivedAccounts() {
        let mtAccount = MTAccount(id: "id123Archived",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345", isArchived: true)
        
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        if !sut.archivedAccounts.isEmpty {
            XCTAssertEqual(sut.archivedAccounts[0].id, "id123Archived")
        }
    }
    
    // MARK: - createAccount test cases
        
    func test_createAccount_whenAccountExistsInLocal_emitsError() throws {
        // given
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])

        let createAccountExpectation = expectation(description: "Did not emit anything")
        // when
        
        var receivedError: MTError?
        
        // address already exists
        sut.createAccount(using: MTAuth(address: "test@domain.com", password: "123456"))
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                    createAccountExpectation.fulfill()
                } else {
                    XCTFail("Error not received")
                }
            } receiveValue: { _ in
                XCTFail("Should not receive valid account")
            }
            .store(in: &subscriptions)

        // then
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
        let error = try XCTUnwrap(receivedError)
        XCTAssertEqual(error.localizedDescription, "This account already exists! Please choose a different address")
    }
    
    func test_createAccount_whenAccountExistsInRemote_emitsError() throws {
        // given
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        initSut(withSucccessfulDomains: givenDomains, accounts: [])
        
        let createAccountExpectation = expectation(description: "Did not emit anything")
        
        accountService.accounts = [mtAccount]
        accountService.error = .mtError("This account already exists! Please choose a different address")
        // when
        
        var receivedError: MTError?
        
        // address alredy exists
        sut.createAccount(using: MTAuth(address: "test@domain.com", password: "123456"))
            .sink { completion in
                if case let .failure(error) = completion {
                    receivedError = error
                    createAccountExpectation.fulfill()
                } else {
                    XCTFail("Error not received")
                }
            } receiveValue: { _ in
                XCTFail("Should not receive valid account")
            }
            .store(in: &subscriptions)

        // then
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedError)
        let error = try XCTUnwrap(receivedError)
        XCTAssertEqual(error.localizedDescription, "This account already exists! Please choose a different address")
    }
    
    func test_createAccount_whenAccountDoesNotExists_createsAndEmitsAccount() throws {
        // given
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        let createAccountExpectation = expectation(description: "Did not emit anything")
        // when
        
        var receivedAccount: Account?

        // address alredy exists
        sut.createAccount(using: MTAuth(address: "new@domain.com", password: "123456"))
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail("Error: \(error.localizedDescription)")
                } else {
                    createAccountExpectation.fulfill()
                }
            } receiveValue: { account in
                receivedAccount = account
            }
            .store(in: &subscriptions)

        // then
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(receivedAccount)
        let account = try XCTUnwrap(receivedAccount)
        XCTAssertEqual(account.address, "new@domain.com")
    }
    
    func test_archiveAccount_setsAccountArchivedProperyToTrue() {
        
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345")
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        // Initially
        XCTAssertFalse(givenAccount.isArchived)
        XCTAssertEqual(sut.activeAccounts.count, 1)
        XCTAssertEqual(sut.archivedAccounts.count, 0)
        
        // When
        sut.archiveAccount(account: givenAccount)
        peristenceManager.saveContext(peristenceManager.mainContext)
        // swiftlint:disable force_cast
        sut.fetchController.delegate!.controllerDidChangeContent!(sut.fetchController as! NSFetchedResultsController<NSFetchRequestResult>)
        // swiftlint:enable force_cast
        
        // Then
        XCTAssertTrue(givenAccount.isArchived)
        XCTAssertEqual(self.sut.activeAccounts.count, 0)
        XCTAssertEqual(self.sut.archivedAccounts.count, 1)
    }
    
    func test_activateAccount_setsAccountArchivedProperyToFalse() {
        
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345", isArchived: true)
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        // Initially
        XCTAssertTrue(givenAccount.isArchived)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        
        // When
        sut.activateAccount(account: givenAccount)
        
        // swiftlint:disable force_cast
        sut.fetchController.delegate!.controllerDidChangeContent!(sut.fetchController as! NSFetchedResultsController<NSFetchRequestResult>)
        // swiftlint:enable force_cast
        
        // Then
        XCTAssertFalse(givenAccount.isArchived)
        XCTAssertEqual(self.sut.activeAccounts.count, 1)
        XCTAssertEqual(self.sut.archivedAccounts.count, 0)
    }
    
    func test_removeAccount_removesAccountFromAnyList() {
        let mtAccount = MTAccount(id: "id123",
                                  address: "test@domain.com",
                                  quotaLimit: 100,
                                  quotaUsed: 10,
                                  isDisabled: false,
                                  isDeleted: false,
                                  createdAt: .init(),
                                  updatedAt: .init())
        let givenAccount = Account(context: peristenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "12345", isArchived: true)
        initSut(withSucccessfulDomains: givenDomains, accounts: [givenAccount])
        
        // Initially
        XCTAssertTrue(givenAccount.isArchived)
        XCTAssertEqual(sut.activeAccounts.count, 0)
        XCTAssertEqual(sut.archivedAccounts.count, 1)
        
        // When
        sut.removeAccount(account: givenAccount)
        peristenceManager.mainContext.delete(givenAccount)
        peristenceManager.saveMainContext()
        // swiftlint:disable force_cast
        sut.fetchController.delegate!.controllerDidChangeContent!(sut.fetchController as! NSFetchedResultsController<NSFetchRequestResult>)
        // swiftlint:enable force_cast
        
        // Then
        XCTAssertEqual(self.sut.activeAccounts.count, 0)
        XCTAssertEqual(self.sut.archivedAccounts.count, 0)
    }
    
 }
