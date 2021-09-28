//
//  MockMTDomainService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation
import Combine
import MailTMSwift

class MockMTDomainService: MTDomainService {

    var getAllDomainsCallCount = 0
    var givenGetAllDomainsResult: Result<[MTDomain], MTError>!
    override func getAllDomains(completion: @escaping (Result<[MTDomain], MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        getAllDomainsCallCount += 1
        completion(givenGetAllDomainsResult)
        return MockDataTask()
    }

    var getDomainCallCount = 0
    var getDomainId: String?
    var givenGetDomainResult: Result<MTDomain, MTError>!
    override func getDomain(id: String, completion: @escaping (Result<MTDomain, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        getDomainCallCount += 1
        getDomainId = id
        completion(givenGetDomainResult)
        return MockDataTask()
    }
    
    var getAllDomainsPublisherCallCount = 0
    var givenGetAllDomainsPubliserResult: Result<[MTDomain], MTError>!
    override func getAllDomains() -> AnyPublisher<[MTDomain], MTError> {
        getAllDomainsPublisherCallCount += 1
        return Future { promise in
            promise(self.givenGetAllDomainsPubliserResult)
        }
        .eraseToAnyPublisher()
        
    }
    
    var getDomainPublisherCallCount = 0
    var getDomainPublisherId: String?
    var givenGetDomainPublisherResult: Result<MTDomain, MTError>!
    override func getDomain(id: String) -> AnyPublisher<MTDomain, MTError> {
        getDomainPublisherCallCount += 1
        getDomainPublisherId = id
        return Future { promise in
            promise(self.givenGetDomainPublisherResult)
        }
        .eraseToAnyPublisher()
    }

}
