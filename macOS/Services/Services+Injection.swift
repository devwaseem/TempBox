//
//  Services+Injection.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Resolver

extension Resolver {
    public static func registerServices() {
        register {
            AccountService()
        }.implements(AccountServiceProtocol.self)
        
        register {
            MessagesListenerService(accountService: resolve())
        }
    }
}
