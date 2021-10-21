//
//  AddAccountViewController.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import Resolver
import Combine
import AppKit
import MailTMSwift
import OSLog

class AddAccountViewController: ObservableObject {
    static let logger = Logger(subsystem: Logger.subsystem, category: String(describing: AddAccountViewController.self))
    @Published var isAddAccountWindowOpen = false
    
    private var accountService: AccountService

    // MARK: Error properties
    @Published var alertMessage: SimpleAlertData?

    // MARK: Domain properties
    var availableDomains: [String] = []
    @Published var selectedDomain = ""
    @Published var isDomainsLoading = true
    
    // MARK: Address properties
    @Published var addressText = "" {
        didSet {
            if addressText != oldValue {
                addressText = addressText.lowercased()
            }
        }
    }

    // MARK: Password properties
    @Published var passwordText = ""
    @Published var shouldGenerateRandomPassword = true

    // MARK: Create Account properties
    @Published var isCreatingAccount = false
    var subscriptions: Set<AnyCancellable> = []

    var isPasswordValid: Bool {
        (passwordText != "" && passwordText.count >= 6) || shouldGenerateRandomPassword
    }

    var canCreate: Bool {
        !isDomainsLoading
        && selectedDomain != ""
        && addressText.count >= 5
        && isPasswordValid
    }

    // MARK: - Methods

    init(accountService: AccountService = Resolver.resolve()) {
        self.accountService = accountService
        
        self.accountService.isDomainsLoadingPublisher
            .assign(to: \.isDomainsLoading, on: self)
            .store(in: &subscriptions)
        
        self.accountService.availableDomainsPublisher
            .map {
                $0.map(\.domain)
            }
            .handleEvents(receiveOutput: { [weak self] domains in
                guard let self = self else { return }
                self.selectedDomain = domains.first ?? ""
            })
            .assign(to: \.availableDomains, on: self)
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: .newAddress)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.isAddAccountWindowOpen = true
            }
            .store(in: &subscriptions)
    }
    
    func openAddAccountWindow() {
        if accountService.totalAccountsCount < AppConfig.maxAccountsAllowed {
            isAddAccountWindowOpen = true
        } else {
            alertMessage = .init(title: "Max Account limit reached", message: "You cannot create more than \(AppConfig.maxAccountsAllowed) accounts")
        }
    }
    
    func closeAddAccountWindow() {
        isAddAccountWindowOpen = false
        alertMessage = nil
        addressText = ""
        passwordText = ""
        NSApp.mainWindow?.endSheet(NSApp.keyWindow!)
    }

    func generateRandomAddress() {
        addressText = String.random(length: 10, allowsUpperCaseCharacters: false)
    }

    func createNewAddress() {
        guard canCreate else {
            return
        }

        let address = addressText + "@" + selectedDomain
        let password: String
        if shouldGenerateRandomPassword {
            password = String.random(length: 12, allowsSpecialCharacters: true)
        } else {
            password = passwordText
        }

        let auth = MTAuth(address: address, password: password)
        isCreatingAccount = true
        self.accountService.createAccount(using: auth)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isCreatingAccount = false
                if case .failure(let error) = completion {
                    Self.logger.error("\(#function) \(#line): \(error.localizedDescription)")
                    switch error {
                    case MTError.mtError(let errorStr):
                        if errorStr.contains("already used")
                            || errorStr.contains("not valid") {
                            self.alertMessage = "This address already exists! Please choose a different address"
                        } else {
                            self.alertMessage = .init(title: errorStr, message: nil)
                        }
                    default:
                        self.alertMessage = "Something went wrong while creating a new address"
                    }
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.closeAddAccountWindow()
            }
            .store(in: &subscriptions)
  
    }

}
