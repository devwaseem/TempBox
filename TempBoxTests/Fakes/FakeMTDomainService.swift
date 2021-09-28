//
//  StubMTDomainService.swift
//  TempBoxTests
//
//  Created by Waseem Akram on 26/09/21.
//

import Foundation
import Combine
import MailTMSwift

class FakeMTDomainService: MTDomainService {

    override func getDomain(id: String, completion: @escaping (Result<MTDomain, MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        completion(.success(getFakeDomain(id: id)))
        return MockDataTask()
    }
    
    override func getAllDomains(completion: @escaping (Result<[MTDomain], MTError>) -> Void) -> MTAPIServiceTaskProtocol {
        completion(.success([getFakeDomain()]))
        return MockDataTask()
    }
    
    override func getDomain(id: String) -> AnyPublisher<MTDomain, MTError> {
        Future { promise in
            promise(.success(self.getFakeDomain(id: id)))
        }
        .eraseToAnyPublisher()
        
    }
    
    override func getAllDomains() -> AnyPublisher<[MTDomain], MTError> {
        Future { promise in
            promise(
                .success([self.getFakeDomain()])
            )
        }
        .eraseToAnyPublisher()
    }
    
    private func getFakeDomain(id: String = UUID().uuidString) -> MTDomain {
        return MTDomain(id: id,
                        domain: "test@test.com",
                        isActive: true,
                        isPrivate: false,
                        createdAt: .init(),
                        updatedAt: .init())
        
    }

}
