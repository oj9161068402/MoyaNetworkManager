//
//  Ring_CryptoUtils.swift
//  FitnessPlan
//
//  Created by 段先生 on 2021/8/9.
//

import Foundation
import CommonCrypto


extension Data {
    func crypt(operation: CCOperation, key: String) -> String? {
        let base64Data = self.base64EncodedData()
        let aseDicString = String(data: base64Data, encoding: .utf8)
        return aseDicString?.crypt(operation: operation, key: key)
    }
}

extension String {
    func crypt(operation: CCOperation, key: String) -> String? {
        if let keyData = key.data(using: .utf8) {
            var cryptData: Data?
            if operation == kCCEncrypt {
                cryptData = self.data(using: .utf8)
            } else {
                cryptData = Data(base64Encoded: self, options: .ignoreUnknownCharacters)
            }
            if cryptData == nil {
                return nil
            }
            let algoritm: CCAlgorithm = CCAlgorithm(kCCAlgorithmDES)
            let option: CCOptions = CCOptions(kCCOptionPKCS7Padding)
            let keyBytes = [UInt8](keyData)
            let keyLength = kCCKeySizeDES
            let dataIn = [UInt8](cryptData!)
            let dataInlength = cryptData!.count
            let dataOutAvailable = Int(dataInlength + kCCBlockSizeDES)
            let dataOut = UnsafeMutablePointer<UInt8>.allocate(capacity: dataOutAvailable)
            let dataOutMoved = UnsafeMutablePointer<Int>.allocate(capacity: 1)
            dataOutMoved.initialize(to: 0)
            let cryptStatus = CCCrypt(operation, algoritm, option, keyBytes, keyLength, keyBytes, dataIn, dataInlength, dataOut, dataOutAvailable, dataOutMoved)
            var data: Data?
            if CCStatus(cryptStatus) == CCStatus(kCCSuccess) {
                data = Data(bytesNoCopy: dataOut, count: dataOutMoved.pointee, deallocator: .none)
            }
            dataOutMoved.deallocate()
            dataOut.deallocate()
            if data == nil {
                return nil
            }
            if operation == kCCEncrypt {
                data = data!.base64EncodedData(options: .lineLength64Characters)
            }
            return String(data: data!, encoding: .utf8)
        }
        return nil
    }
}
