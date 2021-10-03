//
//  FakeMTLiveMessagesService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 30/09/21.
//

import Foundation
import MailTMSwift
import Combine
@testable import TempBox

class FakeMTLiveMessagesService: MTLiveMessageProtocol {
    
    var accountPublisher: AnyPublisher<MTAccount, Never> {
        _accountPublisher.eraseToAnyPublisher()
    }
    
    var messagePublisher: AnyPublisher<MTMessage, Never> {
        _messagePublisher.eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<MTLiveMailService.State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    private var _messagePublisher = PassthroughSubject<MTMessage, Never>()
    private var _accountPublisher = PassthroughSubject<MTAccount, Never>()
    
    @Published
    var state: MTLiveMailService.State = .closed
    
    var isStarted = false

    func start() {
        isStarted = true
        state = .opened
    }
    
    func stop() {
        isStarted = false
        state = .closed
    }
    
    func restart() {
        start()
    }
    
    func emulate(message: MTMessage) {
        self._messagePublisher.send(message)
    }
    
    func emulate(account: MTAccount) {
        self._accountPublisher.send(account)
    }
    
}
