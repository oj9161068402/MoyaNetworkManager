//
//  HKServiceConfig.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/8.
//

import Foundation
import Moya
import FCUUID

// MARK: - 网络请求配置类
class HKServiceConfig {
    /// 单例
    static let shared = HKServiceConfig.init()
    
    let UrlHost = "http://localhost:8080"
    
    /// 发包请求秘钥
    let packageKey = "6d564c0463096524"
    
    /// 设置请求超时时间
    let timeoutInterval: TimeInterval = 40.0
    
    var headers: [String: String]? = configDefaultHeaders()
    
    /// 返回默认参数，接口参数后期覆盖
    var paramters: [String: Any]? = configDefaultParameters()
    
    static func configDefaultHeaders() -> [String: String]? {
        var headers: [String: String]? = ["userId": FCUUID.uuidForDevice()]
        return headers
    }
    
    static func configDefaultParameters() -> [String: Any]? {
        let parameters = ["platform": "iOS"]
        return parameters
    }
    
}
