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
    
    var messagePublisher: AnyPublisher<MTMessage, Never> { get }
    var accountPublisher: AnyPublisher<MTAccount, Never> { get }
    var statePublisher: AnyPublisher<MTLiveMailService.State, Never> { get }
    func start()
    func stop()
    func restart()
    
}

extension MTLiveMailService: MTLiveMessageProtocol {
    
}
