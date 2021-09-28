//
//  Respositories+Injection.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Resolver

extension Resolver {

    static func registerRepositories() {
        register {
            AccountRepository(persistenceManager: resolve())
        }.implements(AccountRepositoryProtocol.self)
    }

}
