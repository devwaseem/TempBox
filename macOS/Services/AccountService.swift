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
}

class AccountService: NSObject, AccountServiceProtocol {
    // MARK: Account properties
    
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
    
    @Published var activeAccounts: [Account] = []
    @Published var archivedAccounts: [Account] = []
    
    // MARK: Domain properties
    @Published var availableDomains: [MTDomain] = []
    @Published var isDomainsLoading = false
        
    private var persistenceManager: PersistenceManager
    private var repository: AccountRepositoryProtocol
    private var accountService: MTAccountService
    private var domainService: MTDomainService
    
    var fetchController: NSFetchedResultsController<Account>
    
    init(
        persistenceManager: PersistenceManager = Resolver.resolve(),
        repository: AccountRepositoryProtocol = Resolver.resolve(),
        accountService: MTAccountService = Resolver.resolve(),
        domainService: MTDomainService = Resolver.resolve(),
        fetchController: NSFetchedResultsController<Account>? = nil) {
            
            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.sortDescriptors = []
            if let fetchController = fetchController {
                self.fetchController = fetchController
            } else {
                self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: persistenceManager.mainContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: "TempBox-Account")
            }
            
            self.repository = repository
            self.domainService = domainService
            self.accountService = accountService
            self.persistenceManager = persistenceManager
            super.init()
            
            runInitialSetup()
            
            do {
                try fetchController?.performFetch()
                accountsdidChange()
            } catch {
                print(error)
            }
        }
    
    private func runInitialSetup() {
        self.getDomains()
        self.fetchController.delegate = self
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    private func getDomains() {
        isDomainsLoading = true
        domainService.getAllDomains()
            .sink { completion in
                self.isDomainsLoading = false
                if case let .failure(error) = completion {
                    print("Error \(error.localizedDescription)")
                }
            } receiveValue: { [unowned self] domains in
                self.availableDomains = domains
                    .filter { $0.isActive && !$0.isPrivate }
            }
            .store(in: &subscriptions)

    }
    
    func createAccount(using auth: MTAuth) -> AnyPublisher<Account, MTError> {
        guard !self.repository.isAccountExists(forAddress: auth.address) else {
            return Future { promise in
                promise(.failure(.mtError("This account already exists! Please choose a different address")))
            }.eraseToAnyPublisher()
        }
        
        return self.accountService.createAccount(using: auth)
            .flatMap { account in
                Publishers.Zip(
                    Deferred {
                        Future<MTAccount, MTError> { promise in
                            promise(.success(account))
                        }
                    },
                    
                    self.accountService.login(using: auth)
                )
            }
            .eraseToAnyPublisher()
            .print()
            .map { (account, token) -> Account in
                self.repository.create(account: account, password: auth.password, token: token)
            }
            .handleEvents(receiveOutput: { account in
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
    }

}

extension AccountService:  NSFetchedResultsControllerDelegate {
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        accountsdidChange()
    }
    
}
