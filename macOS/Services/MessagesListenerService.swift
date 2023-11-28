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
    private var accountRepository: AccountRepository
    private var channels: [Account: MTLiveMessageProtocol] = [:]
    @Published var channelsStatus: [Account: MTLiveMailService.State] = [:]
    
    private var subscriptions = Set<AnyCancellable>()
    
    var onMessageReceivedPublisher: AnyPublisher<MessageReceived, Never> {
        _messageReceivedPublisher.eraseToAnyPublisher()
    }
    
    var onMessageDeletedPublisher: AnyPublisher<MessageReceived, Never> {
        _onMessageDeletedPublisher.eraseToAnyPublisher()
    }
    
    private let _messageReceivedPublisher = PassthroughSubject<MessageReceived, Never>()
    private let _onMessageDeletedPublisher = PassthroughSubject<MessageReceived, Never>()
        
    init(accountService: AccountServiceProtocol, accountRepository: AccountRepository) {
        self.accountRepository = accountRepository
        self.accountService = accountService
        listenToAccounts()
    }
    
    func listenToAccounts() {
        accountService
            .activeAccountsPublisher
            .sink { [weak self] accounts in
                guard let self = self else { return }
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
    
    func addChannelAndStartListening(account: Account) {
        let messageListener = createListener(withToken: account.token, accountId: account.id)
        channels[account] = messageListener
        channelsStatus[account] = .closed
        
        messageListener.messagePublisher.sink { [weak self] message in
            guard let self = self else { return }
            if message.isDeleted {
                self._onMessageDeletedPublisher.send(MessageReceived(account: account, message: message))
            } else {
                self._messageReceivedPublisher.send(MessageReceived(account: account, message: message))
            }
        }
        .store(in: &subscriptions)
        
        messageListener.accountPublisher.sink { [weak self] mtAccount in
            guard let self = self else { return }
            if let account = self.accountRepository.getAccount(fromId: mtAccount.id) {
                account.set(from: mtAccount, password: account.password, token: account.token)
                self.accountRepository.update(account: account)
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
    
    func stopListeningAndRemoveChannel(account: Account) {
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
        return MTLiveMailService(token: token, accountId: accountId)
    }
    
}
