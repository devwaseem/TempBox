//
//  String+Extensions.swift
//  TempBox (macOS)
//
//  Created by Waseem Akram on 22/09/21.
//

import Foundation

extension String {

    static func random(length: Int = 8, allowsSpecialCharacters: Bool = false) -> String {

        let specialChars = allowsSpecialCharacters ? "$@#!&()[]" : ""
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" + specialChars
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
