//
//  Persistence+Injection.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Resolver

extension Resolver {

    static func registerPersistence() {
        register {
            PersistenceManager()
        }
    }

}
