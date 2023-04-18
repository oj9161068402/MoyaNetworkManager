//
//  String+Extension.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/13.
//

import Foundation

// MARK: - 字典扩展
extension Dictionary {
    
    /// json -> JsonString
    public func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self) else { return nil }
        guard let jsonString = String(data: data, encoding: String.Encoding.utf8) else { return nil }
        return jsonString
    }
    
    /// json对象 -> Data
    public func jsonToData() -> Data? {
        if !JSONSerialization.isValidJSONObject(self) {
            print("不是正确的Json对象")
            return nil
        }
        
        // 利用Foundation自带的Json库将：Json -> Data
        // 如果设置options为JSONSerialization.WritingOptions.prettyPrinted，则打印格式更好阅读
        return try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    
}
