//
//  MessagesListenerServiceTests.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 01/10/21.
//

import Foundation
import XCTest
import MailTMSwift
import Combine
@testable import TempBox

class TestableMessagesListenerService: MessagesListenerService {
    
    var mtLiveMessageService: FakeMTLiveMessagesService
    
    init(accountService: AccountServiceProtocol, mtLiveMessageService: FakeMTLiveMessagesService) {
        self.mtLiveMessageService = mtLiveMessageService
        super.init(accountService: accountService)
    }
    
    override func createListener(withToken token: String, accountId: String) -> MTLiveMessageProtocol {
        mtLiveMessageService
    }
    
}

class MessagesListenerServiceTests: XCTestCase {
    
    var persistenceManager: TestPersistenceManager!
    var accountService: FakeAccountService!
    var messageListenerService: FakeMTLiveMessagesService!
    var sut: TestableMessagesListenerService!
    
    var subscriptions = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        persistenceManager = TestPersistenceManager()
        accountService = FakeAccountService()
        messageListenerService = FakeMTLiveMessagesService()
        sut = TestableMessagesListenerService(accountService: accountService, mtLiveMessageService: messageListenerService)
    }
    
    override func tearDown() {
        super.tearDown()
        accountService = nil
        sut = nil
        persistenceManager = nil
        messageListenerService = nil
    }
    
    func getFakeMTAccount() -> MTAccount {
        MTAccount(id: "1234",
                  address: "test@test.com",
                  quotaLimit: 100,
                  quotaUsed: 0,
                  isDisabled: false,
                  isDeleted: false,
                  createdAt: .init(),
                  updatedAt: .init())
    }
    
    func getMTMessage() -> MTMessage {
        MTMessage(id: "test-id",
                  msgid: "test-msgId",
                  from: .init(address: "fromUser@example.com", name: "fromUser"),
                  to: [],
                  cc: [], bcc: [],
                  subject: "test-subject",
                  seen: false,
                  flagged: false,
                  isDeleted: false,
                  retention: false,
                  retentionDate: .init(),
                  text: "",
                  html: [],
                  hasAttachments: false,
                  attachments: [],
                  size: 0,
                  downloadURL: "",
                  createdAt: .init(),
                  updatedAt: .init())
    }
    
    func test_init_whenNewAccountsAdded_createsNewChannelWithAccount() {
        
        let mtAccount = getFakeMTAccount()
        let account = Account(context: persistenceManager.mainContext)
        account.set(from: mtAccount, password: "12345", token: "1234")
        
        // when
        accountService.setActiveAccounts(accounts: [account])
        
        // then
        XCTAssertNotNil(sut.channelsStatus[account])
        XCTAssertEqual(sut.channelsStatus[account], .opened)
        XCTAssertTrue(messageListenerService.isStarted)
        XCTAssertEqual(messageListenerService.state, .opened)
    }
    
    func test_init_whenExistingAccountsRemoved_stopsListeningAndRemoveChannel() {
        
        let mtAccount = getFakeMTAccount()
        let account = Account(context: persistenceManager.mainContext)
        account.set(from: mtAccount, password: "12345", token: "1234")
        
        accountService.setActiveAccounts(accounts: [account])
        
        XCTAssertNotNil(sut.channelsStatus[account])
        XCTAssertEqual(sut.channelsStatus[account], .opened)
        XCTAssertTrue(messageListenerService.isStarted)
        
        // The account is added and live
        // Attempt to remove it
        
        accountService.setActiveAccounts(accounts: [])
        XCTAssertNil(sut.channelsStatus[account])
        XCTAssertFalse(messageListenerService.isStarted)
        XCTAssertEqual(messageListenerService.state, .closed)
    }
    
    func test_whenMTMessageReceived_messagesReceivedPublisherEmitsResult() throws {
        let mtAccount = getFakeMTAccount()
        let givenAccount = Account(context: persistenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "1234")
        
        let givenMessage = getMTMessage()
        
        let messageExpectation = expectation(description: "Message not received")
        var optionalMessageReceived: MessageReceived?
        
        sut.messagesReceivedPublisher.sink { _ in
            XCTFail("Should not receive completion")
        } receiveValue: { messageReceived in
            messageExpectation.fulfill()
            optionalMessageReceived = messageReceived
        }
        .store(in: &subscriptions)

        // when
        accountService.setActiveAccounts(accounts: [givenAccount])
        messageListenerService.state = .opened
        messageListenerService.emulate(message: givenMessage)
        
        // then
        waitForExpectations(timeout: 1)
        XCTAssertNotNil(optionalMessageReceived)
        
        let messageReceived = try XCTUnwrap(optionalMessageReceived)
        XCTAssertEqual(messageReceived.account, givenAccount)
        XCTAssertEqual(messageReceived.message.id, givenMessage.id)
    }
    
    func test_restartChannel_whenCalled_restartsChannel() {
        
        let mtAccount = getFakeMTAccount()
        let givenAccount = Account(context: persistenceManager.mainContext)
        givenAccount.set(from: mtAccount, password: "12345", token: "1234")
        
        // Initally Add a account, make sure, the connection is opened
        accountService.setActiveAccounts(accounts: [givenAccount])
        XCTAssertNotNil(sut.channelsStatus[givenAccount])
        XCTAssertEqual(sut.channelsStatus[givenAccount], .opened)
        XCTAssertTrue(messageListenerService.isStarted)
        XCTAssertEqual(messageListenerService.state, .opened)
        
        messageListenerService.stop() // emulating stop like network error.
        
        // After stopping a connection, make sure, the connection is closed
        XCTAssertFalse(messageListenerService.isStarted)
        XCTAssertEqual(messageListenerService.state, .closed)
        XCTAssertEqual(sut.channelsStatus[givenAccount], .closed)
        
        // when
        sut.restartChannel(account: givenAccount)
        
        // then
        // After restarting a connection, make sure, the connection is opened again
        XCTAssertTrue(messageListenerService.isStarted)
        XCTAssertEqual(messageListenerService.state, .opened)
        XCTAssertEqual(sut.channelsStatus[givenAccount], .opened)
        
    }
    
}
