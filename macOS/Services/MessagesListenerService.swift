//
//  MessageFetchingService.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 28/09/21.
//

import Foundation
import Combine
import Resolver
import MailTMSwift

struct MessageReceived {
    let account: Account
    let message: MTMessage
}

class MessagesListenerService {
    
    private var accountService: AccountServiceProtocol
    private var channels: [Account: MTLiveMessageProtocol] = [:]
    var channelsStatus: [Account: MTLiveMessagesService.State] = [:]
    
    private var subscriptions = Set<AnyCancellable>()
    
    var messagesReceivedPublisher: AnyPublisher<MessageReceived, Never> {
        _messagesReceivedPublisher.eraseToAnyPublisher()
    }
    
    private let _messagesReceivedPublisher = PassthroughSubject<MessageReceived, Never>()
        
    init(accountService: AccountServiceProtocol) {
        self.accountService = accountService
        listenToAccounts()
    }
    
    func listenToAccounts() {
        accountService
            .activeAccountsPublisher
            .sink { accounts in
                let exisitingChannels = Array(self.channels.keys)
                let difference = accounts.difference(from: exisitingChannels)
                difference.insertions.forEach { change in
                    if case let .insert(offset: _, element: account, associatedWith: _) = change {
                        self.addChannelAndStartListening(account: account)
                    }
                }
                
                difference.removals.forEach { change in
                    if case let .remove(offset: _, element: account, associatedWith: _) = change {
                        self.stopListeningAndRemoveChannel(account: account)
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    private func addChannelAndStartListening(account: Account) {
        let messageListener = createListener(withToken: account.token, accountId: account.id)
        channels[account] = messageListener
        channelsStatus[account] = .closed
        
        messageListener.messagePublisher.sink { [weak self] result in
            guard let self = self else { return }
            if case let .success(message) =  result {
                self._messagesReceivedPublisher.send(MessageReceived(account: account, message: message))
            }
            
            if case let .failure(error) =  result {
                print(error)
            }
        }
        .store(in: &subscriptions)
        messageListener.statePublisher
            .sink { [weak self] state in
                guard let self = self else { return }
                self.channelsStatus[account] = state
            }
            .store(in: &subscriptions)
        
        messageListener.start()
    }
    
    private func stopListeningAndRemoveChannel(account: Account) {
        if let existingListener = channels[account] {
            existingListener.stop()
            channels.removeValue(forKey: account)
            channelsStatus.removeValue(forKey: account)
        }
    }
    
    func restartChannel(account: Account) {
        if let existingListener = channels[account] {
            existingListener.restart()
        }
    }
    
    internal func createListener(withToken token: String, accountId: String) -> MTLiveMessageProtocol {
        // NOTE: When testing, This class is replaced with Fake
        return MTLiveMessagesService(token: token, accountId: accountId)
    }
    
}
