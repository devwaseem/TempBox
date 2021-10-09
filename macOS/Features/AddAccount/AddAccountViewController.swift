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

class AddAccountViewController: ObservableObject {
    @Published var isAddAccountWindowOpen = false
    
    private var accountService: AccountService

    // MARK: Error properties
    @Published var errorMessage = ""
    @Published var showErrorAlert = false

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
    }
    
    func openAddAccountWindow() {
        isAddAccountWindowOpen = true
    }
    
    func closeAddAccountWindow() {
        isAddAccountWindowOpen = false
        showErrorAlert = false
        errorMessage = ""
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
                    print(error)
                    self.showErrorAlert = true
                    switch error {
                    case MTError.mtError(let errorStr):
                        if errorStr.contains("already used")
                            || errorStr.contains("not valid") {
                            self.errorMessage = "This address already exists! Please choose a different address"
                        } else {
                            self.errorMessage = errorStr
                        }
                    default:
                        self.errorMessage = "Something went wrong while creating a new address"
                    }
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.closeAddAccountWindow()
            }
            .store(in: &subscriptions)
  
    }

}
