//
//  FakeMTAccountService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import Combine
import MailTMSwift

class FakeMTAccountService: MTAccountService {
    
    var accounts: [MTAccount] = []
    var error: MTError?
    var forceError: Bool = false
    
    override func login(using auth: MTAuth, completion: @escaping (Result<String, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        
        guard !forceError else {
            completion(.failure(error!))
            return MockDataTask()
        }
        
        let account = accounts.first { $0.address == auth.address }
        if let account = account {
            completion(.success(account.id))
        } else {
            guard let error = error else {
                fatalError("Error occured but error not passed")
            }
            completion(.failure(error))
        }
        return MockDataTask()
    }

    override func createAccount(using auth: MTAuth, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        
        guard !forceError else {
            completion(.failure(error!))
            return MockDataTask()
        }
       
        let accountExists = accounts.contains { $0.address == auth.address }
        if accountExists {
            guard let error = error else {
                fatalError("Error occured but error not passed")
            }
            completion(.failure(error))
        } else {
            
            let account = MTAccount(id: UUID().uuidString,
                                    address: auth.address,
                                    quotaLimit: 100,
                                    quotaUsed: 0,
                                    isDisabled: false,
                                    isDeleted: false,
                                    createdAt: .init(),
                                    updatedAt: .init())
            accounts.append(account)
            completion(.success(account))
            
        }
        return MockDataTask()
    }

    override func getMyAccount(token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        
        guard !forceError else {
            completion(.failure(error!))
            return MockDataTask()
        }
        
        let account = accounts.first { $0.id == token }
        if let account = account {
            completion(.success(account))
        } else {
            guard let error = error else {
                fatalError("Error occured but error not passed")
            }

            completion(.failure(error))
        }
        return MockDataTask()
    }

    override func deleteAccount(id: String, token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        
        guard !forceError else {
            completion(.failure(error!))
            return MockDataTask()
        }
           
        let account = accounts.first { $0.id == token }
        if let account = account {
            accounts = accounts.filter { $0.id != token }
            completion(.success(account))
        } else {
            guard let error = error else {
                fatalError("Error occured but error not passed")
            }

            completion(.failure(error))
        }
        return MockDataTask()
    }
    
    override func login(using auth: MTAuth) -> AnyPublisher<String, MTError> {
        guard !forceError else {
            return Future<String, MTError> { promise in
                promise(.failure(self.error!))
            }
            .eraseToAnyPublisher()
        }

        return Future { promise in
            let account = self.accounts.first { $0.address == auth.address }
            if let account = account {
                promise(.success(account.id))
            } else {
                guard let error = self.error else {
                    fatalError("Error occured but error not passed")
                }
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    override func createAccount(using auth: MTAuth) -> AnyPublisher<MTAccount, MTError> {

        guard !forceError else {
            return Future<MTAccount, MTError> { promise in
                promise(.failure(self.error!))
            }
            .eraseToAnyPublisher()
        }

        return Deferred {
            Future { promise in
                let accountExists = self.accounts.contains { $0.address == auth.address }
                if accountExists {
                    guard let error = self.error else {
                        fatalError("Error occured but error not passed")
                    }
                    promise(.failure(error))
                } else {

                    let account = MTAccount(id: UUID().uuidString,
                                            address: auth.address,
                                            quotaLimit: 100,
                                            quotaUsed: 0,
                                            isDisabled: false,
                                            isDeleted: false,
                                            createdAt: .init(),
                                            updatedAt: .init())
                    self.accounts.append(account)
                    promise(.success(account))

                }
            }
        }
        .eraseToAnyPublisher()
        
    }

    override func getMyAccount(token: String) -> AnyPublisher<MTAccount, MTError> {
        guard !forceError else {
            return Future<MTAccount, MTError> { promise in
                promise(.failure(self.error!))
            }
            .eraseToAnyPublisher()
        }
        
        return Future { promise in
            let account = self.accounts.first { $0.id == token }
            if let account = account {
                promise(.success(account))
            } else {
                guard let error = self.error else {
                    fatalError("Error occured but error not passed")
                }

                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    override func deleteAccount(id: String, token: String) -> AnyPublisher<MTAccount, MTError> {
        guard !forceError else {
            return Future<MTAccount, MTError> { promise in
                promise(.failure(self.error!))
            }
            .eraseToAnyPublisher()
        }
           
        return Future { promise in
            let account = self.accounts.first { $0.id == token }
            if let account = account {
                self.accounts = self.accounts.filter { $0.id != token }
                promise(.success(account))
            } else {
                guard let error = self.error else {
                    fatalError("Error occured but error not passed")
                }

                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
        
    }
    
}
