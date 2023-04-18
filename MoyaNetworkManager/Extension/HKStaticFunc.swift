//
//  HKStaticFunc.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/11.
//

import Foundation


/// appVersion
func appVersion() -> String {
    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
    return version
}

// MARK: - 日志打印
func XXLog<T>(_ message: T
              , file: String = #file
              , method: String = #function
              , line: Int = #line) {
    #if DEBUG
    let fileName = (file as NSString).lastPathComponent.components(separatedBy: ".swift").first ?? "未知"
    print("\n************** printStart *******************\n")
    
    print("\(fileName)[\(line)]::\(method):\n\(message)")
    
    print("\n************** printEnd *********************\n")
    #endif
}
