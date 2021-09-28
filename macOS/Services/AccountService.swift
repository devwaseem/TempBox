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

class AccountService: NSObject {
    // MARK: Account properties
    @Published var activeAccounts: [Account] = []
    @Published var archivedAccounts: [Account] = []
    
    // MARK: Domain properties
    @Published var availableDomains: [MTDomain] = []
    @Published var isDomainsLoading = false
        
    private var persistenceManager: PersistenceManager
    private var repository: AccountRepositoryProtocol
    private var accountService: MTAccountService
    private var domainService: MTDomainService
    
    private var fetchController: NSFetchedResultsController<Account>
    
    init(
        persistenceManager: PersistenceManager = Resolver.resolve(),
        repository: AccountRepositoryProtocol = Resolver.resolve(),
        accountService: MTAccountService = Resolver.resolve(),
        domainService: MTDomainService = Resolver.resolve()) {
            
            let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
            fetchRequest.sortDescriptors = []
            self.fetchController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: persistenceManager.mainContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: "TempBox-Account")
            
            self.repository = repository
            self.domainService = domainService
            self.accountService = accountService
            self.persistenceManager = persistenceManager
            super.init()
            
            runInitialSetup()
            
            do {
                try fetchController.performFetch()
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
//        getAllDomainTask = domainService.getAllDomains { [weak self] result in
//            guard let self = self else { return }
//            self.isDomainsLoading = false
//            switch result {
//                case .success(let domains):
//                    self.availableDomains = domains
//                        .filter { $0.isActive && !$0.isPrivate }
//                case .failure(let error):
//                    print("Error \(error.localizedDescription)")
//            }
//        }
        
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
    
//    func createAccount(using auth: MTAuth) -> AnyPublisher<Account, MTError> {
//        Future { [weak self] promise in
//            guard let self = self else { return }
//            guard !self.repository.isAccountExists(forAddress: auth.address) else {
//                promise(.failure(.mtError("This account already exists! Please choose a different address")))
//                return
//            }
//            self.accountService.createAccount(using: auth) { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                    case .success(let account):
//                        print(account)
//                        let createdAccount = self.repository.create(account: account, password: auth.password, token: <#String#>)
//                        self.activeAccounts.append(createdAccount)
//                        promise(.success(createdAccount))
//                    case .failure(let error):
//                        promise(.failure(error))
//                }
//            }
//
//        }
//        .eraseToAnyPublisher()
//    }
    
    func createAccount(using auth: MTAuth) -> AnyPublisher<Account, MTError> {
        guard !self.repository.isAccountExists(forAddress: auth.address) else {
            return Future { promise in
                promise(.failure(.mtError("This account already exists! Please choose a different address")))
            }.eraseToAnyPublisher()
        }
        
        return self.accountService.createAccount(using: auth)
            .flatMap { account in
                Publishers.Zip(
                    Future<MTAccount, MTError> { promise in
                        promise(.success(account))
                    },
                    
                    self.accountService.login(using: auth)
                )
            }
            .map { (account, token) -> Account in
                self.repository.create(account: account, password: auth.password, token: token)
            }
            .print()
            .handleEvents(receiveOutput: { account in
                self.activeAccounts.append(account)
            })
            .eraseToAnyPublisher()
    }
    
    func archiveAccount(account: Account) {
        account.isArchived = true
        repository.update(account: account)
        archivedAccounts.append(account)
        activeAccounts = activeAccounts.filter { $0.id != account.id }
    }
    
    func activateAccount(account: Account) {
        account.isArchived = false
        repository.update(account: account)
        activeAccounts.append(account)
        archivedAccounts = archivedAccounts.filter { $0.id != account.id }
    }
    
    private func accountsdidChange() {
        guard let results = fetchController.fetchedObjects else {
            return
        }
        self.activeAccounts = results.filter {
            !$0.isArchived
        }
        self.archivedAccounts = results.filter {
            $0.isArchived
        }
    }

}

extension AccountService:  NSFetchedResultsControllerDelegate {
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        accountsdidChange()
    }
    
}
