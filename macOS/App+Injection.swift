//
//  App+Injection.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Resolver
import MailTMSwift

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {
        defaultScope = .application
        registerPersistence()
        registerServices()
        registerRepositories()
        registerMailTMClasses()
    }
    
    static func registerMailTMClasses() {
        register {
            MTDomainService()
        }
        .scope(.graph)
        
        register {
            MTAccountService()
        }
        .scope(.graph)
        
        register {
            MTMessageService()
        }
        .scope(.graph)
    }

}
