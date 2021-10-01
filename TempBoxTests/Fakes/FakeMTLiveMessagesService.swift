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
    
    var messagePublisher: AnyPublisher<Result<MTMessage, MTError>, Never> {
        _messagePublihser.eraseToAnyPublisher()
    }
    
    var statePublisher: AnyPublisher<MTLiveMessagesService.State, Never> {
        $state.eraseToAnyPublisher()
    }
    
    private var _messagePublihser = PassthroughSubject<Result<MTMessage, MTError>, Never>()
    
    @Published
    var state: MTLiveMessagesService.State = .closed
    
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
        self._messagePublihser.send(.success(message))
    }
    
    func emulate(error: MTError) {
        self._messagePublihser.send(.failure(error))
    }
    
}
