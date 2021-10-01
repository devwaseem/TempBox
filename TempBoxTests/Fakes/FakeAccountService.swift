//
//  FakeAccountService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 01/10/21.
//

import Foundation
import Combine
import MailTMSwift
@testable import TempBox

class FakeAccountService: AccountServiceProtocol {
    
    var activeAccounts: [Account] = [] {
        didSet {
            _activeAccountsPublisher.send(activeAccounts)
        }
    }
    
    var archivedAccounts: [Account] = [] {
        didSet {
            _archivedAccountsPublisher.send(archivedAccounts)
        }
    }
    
    var availableDomains: [MTDomain] = [] {
        didSet {
            _availableDomainsPublisher.send(availableDomains)
        }
    }
    
    var isDomainsLoading: Bool = false
    
    var activeAccountsPublisher: AnyPublisher<[Account], Never> {
        _activeAccountsPublisher.eraseToAnyPublisher()
    }
    
    var archivedAccountsPublisher: AnyPublisher<[Account], Never> {
        _archivedAccountsPublisher.eraseToAnyPublisher()
    }
    
    var availableDomainsPublisher: AnyPublisher<[MTDomain], Never> {
        _availableDomainsPublisher.eraseToAnyPublisher()
    }
    
    private var _activeAccountsPublisher = PassthroughSubject<[Account], Never>()
    private var _archivedAccountsPublisher = PassthroughSubject<[Account], Never>()
    private var _availableDomainsPublisher =  PassthroughSubject<[MTDomain], Never>()
    
    func setIsDomainsLoading(value: Bool) {
        isDomainsLoading = value
    }
    
    func setAvailableDomains(domains: [MTDomain]) {
        self.availableDomains = domains
    }
    
    func setActiveAccounts(accounts: [Account]) {
        self.activeAccounts = accounts
    }
    
    func setArchivedAccounts(accounts: [Account]) {
        self.archivedAccounts = accounts
    }
    
    func archiveAccount(account: Account) {
        account.isArchived = true
        archivedAccounts.append(account)
        activeAccounts = activeAccounts.filter { $0.id != account.id }
    }
    
    func activateAccount(account: Account) {
        account.isArchived = false
        activeAccounts.append(account)
        archivedAccounts = archivedAccounts.filter { $0.id != account.id }
    }
    
    func removeAccount(account: Account) {
        activeAccounts = activeAccounts.filter { $0.id != account.id }
        archivedAccounts = archivedAccounts.filter { $0.id != account.id }
    }
    
    func deleteAndRemoveAccount(account: Account) -> AnyPublisher<Never, MTError> {
        removeAccount(account: account)
        return Future { _ in }.eraseToAnyPublisher()
        
    }
    
}
