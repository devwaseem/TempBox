//
//  MTLiveMessagesService+Extensions.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 01/10/21.
//

import Foundation
import Combine
import MailTMSwift

protocol MTLiveMessageProtocol {
    
    var messagePublisher: AnyPublisher<Result<MTMessage, MTError>, Never> { get }
    var statePublisher: AnyPublisher<MTLiveMessagesService.State, Never> { get }
    func start()
    func stop()
    func restart()
    
}

extension MTLiveMessagesService: MTLiveMessageProtocol {
    
}
