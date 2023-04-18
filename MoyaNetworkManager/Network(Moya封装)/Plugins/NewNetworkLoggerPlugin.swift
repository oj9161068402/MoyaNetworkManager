//
//  NewNetworkLoggerPlugin.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/12.
//

import Foundation
import Moya

/**
 Moya默认四个插件：
 
 AccessTokenPlugin 管理AccessToken的插件
 CredentialsPlugin 管理认证的插件
 NetworkActivityPlugin 管理网络状态的插件
 NetworkLoggerPlugin 管理网络log的插件
 */

// MARK: - 自定义日志打印 plugin (代替NetworkLoggerPlugin)
class NewNetworkLoggerPlugin: PluginType {
    
    /// 请求发送前的编辑（加密），例如添加headers
    func prepare(_ request: URLRequest, target: HKServiceType) -> URLRequest {
//        request.cachePolicy
        return request
    }
    
    /// 发送请求前调用
    func willSend(_ request: RequestType, target: HKServiceType) {
        print("will send request: \(request.request?.url?.absoluteString ?? "")")
    }
    
    /// 收到响应后调用 -> error状况
    func didReceive(_ result: Result<Response, MoyaError>, target: HKServiceType) {
        #if DEBUG
        switch result {
        case let .success(response):
            do {
                XXLog("网络请求成功：\(target.task)")
                _ = try response.filterSuccessfulStatusAndRedirectCodes()
            } catch let error {
                // 请求参数信息
                let parametersMsg = target.parameters != nil ? target.parameters?.toJsonString() ?? "" : "空"
                
                XXLog("网络请求失败!\n"
                      + "==== 错误码 ==== \(response.statusCode)\n"
                      + "==== URL地址 ==== " + target.baseURL.absoluteString + "/" + target.path + "\n"
                      + "==== 请求参数 ==== " + parametersMsg + "\n"
                      + "==== 错误信息 ==== \(error.localizedDescription)")
            }
            break
        case .failure(let error):
            var errorMsg: String = error.errorDescription ?? "未知"
            XXLog("网络请求失败!\n"
                  + "错误码 ===== \(error.response?.statusCode ?? -1)\n"
                  + "URL地址 ===== " + target.baseURL.absoluteString + "/" + target.path + "\n"
                  + "错误信息 ==== \(errorMsg)")
            break
        }
        #endif
    }
    
    /// completion执行前对result的编辑(解密) -> success状况
    func process(_ result: Result<Response, MoyaError>, target: HKServiceType) -> Result<Response, MoyaError> {
        var result = result // 变量
        switch result {
        case .success(let response):
            do {
                _ = try response.filterSuccessfulStatusAndRedirectCodes()
                /// 对响应数据进行解密，然后再封装成一个新的响应，然后返回
                if target.isEncryption {
                    // 对加密数据进行解密
                    let responseJson = RING_CryptoUtils.decryptString(response.data, key: decryptionKey) as! [String: Any]
                    let responseData = responseJson.jsonToData()
                    // 对响应数据重新封装
                    let newResponse = Response(statusCode: response.statusCode, data: responseData ?? Data(), request: response.request, response: response.response)
                    let newResult = Result<Response, MoyaError>.success(newResponse)
                    
                    // 打印日志
                    print("++++++++++++++接口请求信息+++++++++++++++")
                    print("接口信息：\(target.apiDescription ?? "")")
                    print("请求路径：\(target.baseURL.appendingPathComponent(target.path))")
                    if let parameters = target.parameters {
                        print("请求参数：\(String(describing: parameters))")
                    } else {
                        print("请求参数：空")
                    }
                    print("成功响应 ==== " + "\((try? newResponse.mapJSON() as? [String: Any])?.toJsonString() ?? "")")
                    print("++++++++++++++**********+++++++++++++++")
                    return newResult
                } else {
                    // 未加密的情况，只返回code和msg信息
                    // response.data原信息被拦截
                    let dict = ["code": "0", "msg": "此请求数据未加密"]
                    let newResponse = Response(statusCode: response.statusCode, data: dict.jsonToData() ?? Data(), request: response.request, response: response.response)
                    return .success(newResponse)
                }
            } catch _ {}
            
            return result
        default:
            return result
        }
    }
    
}
