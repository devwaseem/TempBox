//
//  AppController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 16/09/21.
//

import Foundation
import MailTMSwift
import Resolver
import Combine
import os
import AppKit

class AppController: ObservableObject {
    @Published var filterNotSeen = false
    
    @Published private(set) var activeAccounts: [Account] = []
    @Published private(set) var archivedAccounts: [Account] = []
    @Published private(set) var accountMessages: [Account: MessageStore] = [:]
    @Published private var accountStatus: [Account: MTLiveMailService.State] = [:]
    
    @Published var selectedAccount: Account?
    @Published var selectedMessage: Message? {
        didSet {
            guard
                let selectedAccount = selectedAccount,
                let selectedMessage = selectedMessage
            else {
                return
            }
            
            markMessageAsSeen(message: selectedMessage, for: selectedAccount)
            fetchCompleteMessageAndUpdate(message: selectedMessage, for: selectedAccount)
        }
    }
    
    var selectedAccountMessages: [Message] {
        
        if let selectedAccount = selectedAccount,
           let exisitingMessageStore = accountMessages[selectedAccount] {
            let messages: [Message]
            if filterNotSeen {
                messages = exisitingMessageStore.messages.filter { !$0.data.seen }
            } else {
                messages = exisitingMessageStore.messages
            }
            return messages.sorted {
                $0.data.createdAt > $1.data.createdAt
            }
        }
        
        return []
    }
    
    var selectedAccountConnectionIsActive: Bool {
        guard let selectedAccount = selectedAccount else {
            return false
        }
        
        return accountStatus[selectedAccount, default: .closed] == .opened
    }
    
    var mtMessageService: MTMessageService
    var accountService: AccountServiceProtocol
    var messageListenerService: MessagesListenerService
    var subscriptions = Set<AnyCancellable>()
    
    var showError = false
    var errorMessage = ""
    
    init(
        accountService: AccountServiceProtocol = Resolver.resolve(),
        messageService: MTMessageService = Resolver.resolve(),
        messageListenerService: MessagesListenerService = Resolver.resolve()
    ) {
        self.accountService = accountService
        self.mtMessageService = messageService
        self.messageListenerService = messageListenerService
        accountService
            .activeAccountsPublisher
            .sink { [weak self] accounts in
                guard let self = self else { return }
                let difference = accounts.difference(from: self.activeAccounts)
                difference.insertions.forEach { change in
                    if case let .insert(offset: _, element: insertedAccount, associatedWith: nil) = change {
                        self.onAccountAddedToActiveAccounts(account: insertedAccount)
                    }
                }
                difference.removals.forEach { change in
                    if case let .remove(offset: _, element: removedAccount, associatedWith: nil) = change {
                        self.onAccountDeletedFromActiveAccounts(account: removedAccount)
                    }
                }
                self.activeAccounts = accounts
            }
            .store(in: &subscriptions)
        
        accountService
            .archivedAccountsPublisher
            .assign(to: \.archivedAccounts, on: self)
            .store(in: &subscriptions)
        
        messageListenerService
            .onMessageReceivedPublisher
            .sink { [weak self] messageReceived in
                guard let self = self else { return }
                self.upsertMessage(message: Message(data: messageReceived.message), for: messageReceived.account)
            }
            .store(in: &subscriptions)
        
        messageListenerService
            .onMessageDeletedPublisher
            .sink { [weak self] messageReceived in
                guard let self = self else { return }
                if self.accountMessages[messageReceived.account] != nil {
                    self.accountMessages[messageReceived.account]?.messages.removeAll(where: {
                        $0.data.id == messageReceived.message.id
                    })
                }
            }
            .store(in: &subscriptions)
        
        messageListenerService
            .$channelsStatus
            .assign(to: \.accountStatus, on: self)
            .store(in: &subscriptions)
        
    }
    
    private func upsertMessage(message: Message, for account: Account) {
        if let messages = self.accountMessages[account]?.messages {
            var updatedMessages = messages
            if let index = messages.firstIndex(of: message) {
                let oldIntro = updatedMessages[index].data.intro
                var updatedMessage = message
                updatedMessage.data.intro = oldIntro ?? message.data.intro ?? "" // preserve old intro.
                updatedMessages[index] = updatedMessage
            } else {
                updatedMessages.append(message)
            }
            self.accountMessages[account]?.messages = updatedMessages
            if let selectedMessage = selectedMessage, selectedMessage.id == message.id {
                self.selectedMessage = message
            }
        }
    }
    
    private func fetchInitialMessagesAndSave(forAccount account: Account) {
        accountMessages[account]?.isFetching = true
        mtMessageService.getAllMessages(token: account.token)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case let .failure(error) = completion {
                    self.accountMessages[account] = MessageStore(isFetching: false, error: error, messages: [])
                }
            } receiveValue: { [weak self] messages in
                guard let self = self else { return }
                let messages = messages.map {
                    Message(data: $0)
                }
                self.accountMessages[account] = MessageStore(isFetching: false, error: nil, messages: messages)
            }
            .store(in: &subscriptions)
    }
    
    func markMessageAsSeen(message: Message, for account: Account) {
        guard
            let message = self.accountMessages[account]?.messages.first(where: { $0.data.id == message.data.id }),
            !message.data.seen
        else {
            return
        }
        mtMessageService.markMessageAs(id: message.data.id, seen: true, token: account.token)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] updatedMessage in
                guard let self = self else { return }
                self.upsertMessage(message: Message(data: updatedMessage), for: account)
            }
            .store(in: &subscriptions)
        
    }
    
    private func fetchCompleteMessageAndUpdate(message: Message, for account: Account) {
        guard
            let message = self.accountMessages[account]?.messages.first(where: { $0.data.id == message.data.id }),
            !message.isComplete
        else {
            return
        }
        let token = account.token
        let messageId = message.data.id
        mtMessageService.getMessage(id: messageId, token: token)
            .sink { completion in
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { [weak self] completeMessage in
                guard let self = self else { return }
                self.upsertMessage(message: Message(isComplete: true,
                                                    data: completeMessage),
                                   for: account)
            }
            .store(in: &subscriptions)
    }
    
    private func onAccountAddedToActiveAccounts(account: Account) {
        accountMessages[account] = MessageStore(isFetching: true, error: nil, messages: [])
        fetchInitialMessagesAndSave(forAccount: account)
    }
    
    private func onAccountDeletedFromActiveAccounts(account: Account) {
        if accountMessages[account] != nil {
            accountMessages.removeValue(forKey: account)
        }
    }
    
    func archiveAccount(account: Account) {
        accountService.archiveAccount(account: account)
    }
    
    func activateAccount(account: Account) {
        accountService.activateAccount(account: account)
    }
    
    func removeAccount(account: Account) {
        accountService.removeAccount(account: account)
    }
    
    func deleteAccount(account: Account) {
        accountService.deleteAndRemoveAccount(account: account)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.showError = false
                if case let .failure(error) = completion {
                    print(error)
                    switch error {
                        case .mtError(let apiError):
                            self.showError = true
                            self.errorMessage = apiError
                        default:
                            break
                    }
                }
            } receiveValue: { _ in
                // Deleted successfully
            }
            .store(in: &subscriptions)
    }
    
    func deleteMessage(message: Message, for account: Account) {
        
        // remove the message first then delete it
        if let messages = self.accountMessages[account]?.messages, let index = messages.firstIndex(of: message) {
            self.accountMessages[account]?.messages.remove(at: index)
        } else {
            return
        }
        
        if self.selectedMessage == message {
            self.selectedMessage = nil
        }
        
        mtMessageService.deleteMessage(id: message.id, token: account.token)
            .sink { completion in                
                if case let .failure(error) = completion {
                    print(error)
                }
            } receiveValue: { _ in
            }
            .store(in: &subscriptions)
    }
        
}
