//
//  HKServiceType.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/8.
//

import Foundation
import Moya

// MARK: - 扩展的TargetType属性
public protocol HKServiceType: TargetType {
    
    /// 接口名称描述
    var apiDescription: String? { get }
    
    /// 请求参数
    var parameters: [String: Any]? { get }
    
    /// 是否需要加密 (不同的API接口可以自定义设置是否加密)
    var isEncryption: Bool { get }
    
    /// 是否在请求头添加appVersion (不同的API接口可以自定义设置是否添加)
    var isHeaderAppVersion: Bool { get }
    
    var isShowLoading: Bool { get }
    
    /// 是否需要授权认证 (token或jwt是否添加到请求头中)
    var needsAuth: Bool { get }
}

// MARK: - 对TargetType修改
extension HKServiceType {
    var baseURL: URL {
        return URL(string: HKServiceConfig.shared.UrlHost)!
    }
    
    var headers: [String: String]? {
        var headers = HKServiceConfig.shared.headers
        if isHeaderAppVersion {
            headers?["version"] = appVersion()
        }
        return headers
    }
    
    var parameters: [String: Any]? {
        // 返回默认参数，接口参数后期覆盖
        return HKServiceConfig.shared.paramters
    }
    
    /// 返回可能带参数的默认task默认属性：request upload download
    var task: Task {
        // 编码方式
        let encoding: ParameterEncoding
        switch self.method {
        case .post:
            encoding = JSONEncoding.default
        default:
            encoding = URLEncoding.default
        }
        // 判断是否含有参数
        if let parameters = self.parameters {
            return .requestParameters(parameters: parameters, encoding: encoding)
        }
        return .requestPlain
    }
    
    /// 请求方式 默认POST
    var method: Moya.Method {
        return .post
    }
    
    var isEncryption: Bool {
        return true
    }
    
    var isHeaderAppVersion: Bool {
        return false
    }
    
    var isShowLoading: Bool {
        return false
    }
    
    var needsAuth: Bool {
        return false
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    /// 测试使用
    var sampleData: Data {
        return "{response: test data}".data(using: String.Encoding.utf8)!
    }
    
}

