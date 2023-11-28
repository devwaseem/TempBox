//
//  AccountService.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import Resolver
import Combine
import MailTMSwift
import CoreData
import OSLog

protocol AccountServiceProtocol {
    var activeAccountsPublisher: AnyPublisher<[Account], Never> { get }
    var archivedAccountsPublisher: AnyPublisher<[Account], Never> { get }
    var availableDomainsPublisher: AnyPublisher<[MTDomain], Never> { get }
    
    var activeAccounts: [Account] { get }
    var archivedAccounts: [Account] { get }
    var availableDomains: [MTDomain] { get }
    var isDomainsLoading: Bool { get }
    
    func archiveAccount(account: Account)
    func activateAccount(account: Account)
    func removeAccount(account: Account)
    func deleteAndRemoveAccount(account: Account) -> AnyPublisher<Never, MTError>
    func refreshAccount(with account: Account) -> AnyPublisher<Bool, MTError>
}

class AccountService: NSObject, AccountServiceProtocol {
    // MARK: Account properties
    static let logger = Logger(subsystem: Logger.subsystem, category: String(describing: AccountService.self))
    var activeAccountsPublisher: AnyPublisher<[Account], Never> {
        $activeAccounts.eraseToAnyPublisher()
    }
    
    var archivedAccountsPublisher: AnyPublisher<[Account], Never> {
        $archivedAccounts.eraseToAnyPublisher()
    }
    
    var availableDomainsPublisher: AnyPublisher<[MTDomain], Never> {
        $availableDomains.eraseToAnyPublisher()
    }
    
    var isDomainsLoadingPublisher: AnyPublisher<Bool, Never> {
        $isDomainsLoading.eraseToAnyPublisher()
    }
    
    var totalAccountsCount = 0
    @Published var activeAccounts: [Account] = []
    @Published var archivedAccounts: [Account] = []
    
    // MARK: Domain properties
    @Published var availableDomains: [MTDomain] = []
    @Published var isDomainsLoading = false
        
    private var persistenceManager: PersistenceManager
    private var repository: AccountRepositoryProtocol
    private var mtAccountService: MTAccountService
    private var domainService: MTDomainService
    
    var subscriptions = Set<AnyCancellable>()
    
    private let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
    
    var fetchController: NSFetchedResultsController<Account>
    
    init(
        persistenceManager: PersistenceManager,
        repository: AccountRepositoryProtocol,
        accountService: MTAccountService,
        domainService: MTDomainService,
        fetchController: NSFetchedResultsController<Account>? = nil) {
            
            fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Account.createdAt, ascending: false)]
            if let fetchController = fetchController {
                self.fetchController = fetchController
            } else {
                self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistenceManager.mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
            }
            self.repository = repository
            self.domainService = domainService
            self.mtAccountService = accountService
            self.persistenceManager = persistenceManager
            super.init()
            
            self.getDomains()
            self.fetchController.delegate = self
            try? self.fetchController.performFetch()
            accountsdidChange()
        }
    
    private func getDomains() {
        isDomainsLoading = true
        domainService.getAllDomains()
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isDomainsLoading = false
                if case let .failure(error) = completion {
                    Self.logger.error("\(#function) \(#line): \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] domains in
                guard let self = self else { return }
                self.availableDomains = domains
                    .filter { $0.isActive && !$0.isPrivate }
            }
            .store(in: &subscriptions)

    }
    
    func refreshAccount(with account: Account) -> AnyPublisher<Bool, MTError> {
        let auth = MTAuth(address: account.address, password: account.password)

        return Future<Bool, MTError> { promise in
            self.mtAccountService.login(using: auth) { [weak self] result in
                switch result {
                case .success(let token):
                    account.token = token
                    self?.repository.update(account: account)
                    promise(.success(true))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createAccount(using auth: MTAuth) -> AnyPublisher<Account, MTError> {
        guard !self.repository.isAccountExists(forAddress: auth.address) else {
            return Future { promise in
                promise(.failure(.mtError("This account already exists! Please choose a different address")))
            }.eraseToAnyPublisher()
        }
        
        return self.mtAccountService.createAccount(using: auth)
            .flatMap { account in
                Publishers.Zip(
                    Deferred {
                        Future<MTAccount, MTError> { promise in
                            promise(.success(account))
                        }
                    },
                    
                    self.mtAccountService.login(using: auth)
                )
            }
            .eraseToAnyPublisher()
            .compactMap { [weak self] (account, token) -> Account? in
                guard let self = self else { return nil }
                return self.repository.create(account: account, password: auth.password, token: token)
            }
            .handleEvents(receiveOutput: { [weak self] account in
                guard let self = self else { return }
                self.activeAccounts.append(account)
            })
            .eraseToAnyPublisher()
    }
    
    func archiveAccount(account: Account) {
        account.isArchived = true
        repository.update(account: account)
    }
    
    func activateAccount(account: Account) {
        account.isArchived = false
        repository.update(account: account)
    }
    
    func removeAccount(account: Account) {
        repository.delete(account: account)
    }
    
    func deleteAndRemoveAccount(account: Account) -> AnyPublisher<Never, MTError> {
        self.mtAccountService.deleteAccount(id: account.id, token: account.token)
            .share()
            .ignoreOutput()
            .handleEvents(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                if case .finished = completion {
                    self.removeAccount(account: account)
                }
            })
            .eraseToAnyPublisher()
    }
    
    private func accountsdidChange() {
        guard let results = fetchController.fetchedObjects else {
            return
        }
        var tempActiveAccounts = [Account]()
        var tempArchivedAccounts = [Account]()
        for result in results where !result.isDeleted {
            if result.isArchived {
                tempArchivedAccounts.append(result)
            } else {
                tempActiveAccounts.append(result)
            }
        }
        
        activeAccounts = tempActiveAccounts
        archivedAccounts = tempArchivedAccounts
        self.totalAccountsCount = results.count
    }

}

extension AccountService: NSFetchedResultsControllerDelegate {
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        accountsdidChange()
    }
    
}
