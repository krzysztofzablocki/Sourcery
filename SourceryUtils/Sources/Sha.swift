//
// Created by Krzysztof Zablocki on 10/01/2017.
// Copyright (c) 2017 Pixle. All rights reserved.
//

import Foundation
#if canImport(ObjectiveC)
import CommonCrypto
#else
import Crypto
#endif

extension Data {
    public func sha256() -> Data {
#if canImport(ObjectiveC)
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes { (pointer) -> Void in
            _ = CC_SHA256(pointer.baseAddress, CC_LONG(pointer.count), &hash)
        }
        return Data(hash)
        #else
        let digest = SHA256.hash(data: self)
        return Data(digest)
        #endif
    }
}

extension String {
    public func sha256() -> String? {
        guard let data = data(using: String.Encoding.utf8) else { return nil }
        let rc = data.sha256().base64EncodedString(options: [])
        return rc
    }
}
