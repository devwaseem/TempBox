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
    
    var showError = false
    var errorMessage = ""

    init(
        accountService: AccountServiceProtocol = Resolver.resolve(),
        messageListenerService: MessagesListenerService = Resolver.resolve()
    ) {
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
    
}

//{
//    "address": "randommmmm@uniromax.com",
//    "password": "helo12312312"
//}
