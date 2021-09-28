//
//  MockMTAccountService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import Combine
import MailTMSwift

class MockMTAccountService: MTAccountService {

    var loginCallCount = 0
    var loginAuth: MTAuth?
    var givenLoginResult: Result<String, MTError>!
    override func login(using auth: MTAuth, completion: @escaping (Result<String, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        loginCallCount += 1
        self.loginAuth = auth
        completion(givenLoginResult)
        return MockDataTask()
    }

    var createAccountCallCount = 0
    var createAccountAuth: MTAuth?
    var givenCreateAccountResult: Result<MTAccount, MTError>!
    override func createAccount(using auth: MTAuth, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        createAccountCallCount += 1
        self.createAccountAuth = auth
        completion(givenCreateAccountResult)
        return MockDataTask()
    }

    var getMyAccountCallCount = 0
    var getMyAccountToken: String?
    var givenGetMyAccountResult: Result<MTAccount, MTError>!
    override func getMyAccount(token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        getMyAccountCallCount += 1
        getMyAccountToken = token
        completion(givenGetMyAccountResult)
        return MockDataTask()
    }

    var deleteAccountCallCount = 0
    var deleteAccountToken: String?
    var deleteAccountResult: Result<MTAccount, MTError>!
    override func deleteAccount(id: String, token: String, completion: @escaping (Result<MTAccount, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        deleteAccountCallCount += 1
        deleteAccountToken = token
        completion(deleteAccountResult)
        return MockDataTask()
    }

    var loginPublisherCallCount = 0
    var loginPublisherAuth: MTAuth?
    var givenLoginPublisherResult: Result<String, MTError>!
    override func login(using auth: MTAuth) -> AnyPublisher<String, MTError> {
        loginPublisherCallCount += 1
        loginPublisherAuth = auth
        return Future { promise in
            promise(self.givenLoginPublisherResult)
        }
        .eraseToAnyPublisher()
    }
    
    var createAccountPublisherCallCount = 0
    var createAccountPublisherAuth: MTAuth?
    var givenCreateAccountPublisherResult: Result<MTAccount, MTError>!
    override func createAccount(using auth: MTAuth) -> AnyPublisher<MTAccount, MTError> {
        createAccountPublisherCallCount += 1
        createAccountPublisherAuth = auth
        return Future { promise in
            promise(self.givenCreateAccountPublisherResult)
        }
        .eraseToAnyPublisher()
    }
    
    override func getMyAccount(token: String) -> AnyPublisher<MTAccount, MTError> {
        fatalError()
    }
    
    override func deleteAccount(id: String, token: String) -> AnyPublisher<MTAccount, MTError> {
        fatalError()
    }
}
