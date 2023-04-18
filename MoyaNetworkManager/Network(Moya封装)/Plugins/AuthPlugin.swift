//
//  AuthPlugin.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/14.
//

import Foundation
import Moya

/**
 AuthorizationType认证方式区别：
 Bearer 基于token的身份验证方式，通常放置在请求的Authorization头部中。一般结合OAuth2.0授权框架判断请求权限
 Basic  基于用户名和密码的身份验证方式，在请求中将用户名和密码编码为Base64字符串，并在Authorization头部中携带，形式为"Basic <base64-encoded-credentials>"。不加密不安全，不能使用在不安全的连接上，如http。
 */

// MARK: - 授权 plugin (与AccessTokenPlugin实现的功能一样)
public final class AuthPlugin: PluginType {
    
    public typealias TokenClosure = (_ target: HKServiceType) -> String?
    
    public let tokenClosure: TokenClosure
    
    public init(tokenClosure: @escaping TokenClosure) {
        self.tokenClosure = tokenClosure
    }
    
    public func prepare(_ request: URLRequest, target: HKServiceType) -> URLRequest {
        guard let token = self.tokenClosure(target), target.needsAuth else { return request }
        
        var request = request
        let authValue = AuthorizationType.bearer.value + " " + token
        request.addValue(authValue, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
}
