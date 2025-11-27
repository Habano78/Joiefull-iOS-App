//
//  String+SHA1.swift
//  Joiefull
//
//  Created by Perez William on 26/11/2025.
//

import Foundation
import CommonCrypto

extension String {
    var sha1: String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))

        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
