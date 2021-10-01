//
//  String+Extensions.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation

extension String {

    static func random(length: Int = 8, allowsUpperCaseCharacters: Bool = true, allowsSpecialCharacters: Bool = false) -> String {

        var allowedChars = "abcdefghijklmnopqrstuvwxyz0123456789"
        
        if allowsUpperCaseCharacters {
            allowedChars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        }
        
        if allowsSpecialCharacters {
            allowedChars += "$@#!&()[]"
        }
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
}
