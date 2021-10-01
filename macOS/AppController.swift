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

class AppController: ObservableObject {
    
    @Published var selectedAccount: Account?
    @Published private(set) var activeAccounts: [Account] = []
    @Published private(set) var archivedAccounts: [Account] = []
    @Published private(set) var accountMessages: [String: [MTMessage]] = [:]
    
    var selectedAccountMessages: [MTMessage] {
        
        if let selectedAccount = selectedAccount,
           let exisitingMessages = accountMessages[selectedAccount.id] {
            return exisitingMessages
        }
        
        return []
    }
    
    var accountService: AccountServiceProtocol
    var messageListenerService: MessagesListenerService
    var subscriptions = Set<AnyCancellable>()

    init(
        accountService: AccountServiceProtocol = Resolver.resolve(),
        messageListenerService: MessagesListenerService = Resolver.resolve()
    ) {
        Logger.persistence.info("Helooooo")
        self.accountService = accountService
        self.messageListenerService = messageListenerService
        accountService
            .activeAccountsPublisher
            .assign(to: \.activeAccounts, on: self)
            .store(in: &subscriptions)
        
        accountService
            .archivedAccountsPublisher
            .assign(to: \.archivedAccounts, on: self)
            .store(in: &subscriptions)
    }
     
    func archiveAccount(account: Account) {
        accountService.archiveAccount(account: account)
    }
    
    func activateAccount(account: Account) {
        accountService.activateAccount(account: account)
    }
    
}

//{
//    "address": "randommmmm@uniromax.com",
//    "password": "helo12312312"
//}
