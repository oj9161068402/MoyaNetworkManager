//
//  HKServiceProvider.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/8.
//

import Foundation
import Moya
import HandyJSON

/// 源文件可访问作用域，范围比private更大
fileprivate let RESULT_CODE_KEY = "code"
fileprivate let RESULT_MSG_KEY = "msg"
fileprivate let RESULT_DATA_KEY = "data"

// MARK: - 网络请求调用者
class HKServiceProvider<APITarget: TargetType> {
    /// 内部使用MoyaProvider对象
    private let moyaProvider: MoyaProvider<APITarget>
    
    static var plugins: [PluginType] {
        let activityPlugin = NewNetworkActivityPlugin { (change, target) in
            if let target = target as? HKServiceType {
                switch change {
                case .began:
                    if target.isShowLoading {}
                    break
                case .ended:
                    if target.isShowLoading {}
                    break
                }
            }
        }
        
        /// 自定义日志插件
        let loggerPlugin = NewNetworkLoggerPlugin()
        
        /// 授权认证token插件
        let authPlugin = AuthPlugin { target in
            return "token"
        }
        
        return [loggerPlugin]
    }
    
    // MARK: - 逃逸闭包
    typealias SuccessJsonBlock = (_ json: [String: Any]?) -> Void // json: [code, msg, data]
    /// 注意： data: Any?类型为Any?，是因为data可以转换类型为[Any]?和[String: Any]?两种类型
    typealias SuccessDataBlock = (_ code: Int?, _ msg: String?, _ data: Any?, _ jsonString: String?) -> Void // code, msg, data, jsonString
    typealias SuccessModelBlock<ModelType> = (_ code: Int?, _ msg: String?, _ model: ModelType?, _ jsonStr: String?) -> Void // code, msg, model, jsonString
    typealias SuccessListModelBlock<ModelType> = (_ code: Int?, _ msg: String?, _ modelList: [ModelType?]?, _ jsonStr: String?) -> Void // code, msg, [model], jsonString
    
    /// result: .success(code, msg, data, jsonString)
    /// 注意： data: Any?类型为Any?，是因为data可以转换类型为[Any]?和[String: Any]?两种类型
    typealias CompletionResultJsonBlock = (_ result: Result<(code: Int?, msg: String?, data: Any?, jsonString: String?), Swift.Error>) -> Void
    /// result: .success(code, msg, model, jsonString)
    typealias CompletionResultModelBlock<ModelType> = (_ result: Result<(code: Int?, msg: String?, model: ModelType?, jsonString: String?), Swift.Error>) -> Void
    /// result: .success(code, msg, [model], jsonString)
    typealias CompletionResultModelListBlock<ModelType> = (_ result: Result<(code: Int?, msg: String?, model: [ModelType?]?, jsonString: String?), Swift.Error>) -> Void
    
    typealias FailureBlock = (_ error: Swift.Error) -> Void // error
    
    init(moyaProvider: MoyaProvider<APITarget> = newDeafultProvider()) {
        self.moyaProvider = moyaProvider
    }
}

// MARK: - 覆盖MoyaProvider属性
extension HKServiceProvider {
    public static func newDeafultProvider() -> MoyaProvider<APITarget> {
        let moyaProvider = MoyaProvider<APITarget>(
            endpointClosure: HKServiceProvider<APITarget>.endpointClosure()
            , requestClosure: HKServiceProvider<APITarget>.requestClosure()
            , stubClosure: MoyaProvider.neverStub(_:)
            , plugins: plugins)
        
        return moyaProvider
    }
    
    /// Target -> Endpoint （可以在此自定义附加参数）
    static func endpointClosure() -> MoyaProvider<APITarget>.EndpointClosure {
        return { target in
            var defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
            // 在请求头添加新参数
            return defaultEndpoint.adding(newHTTPHeaderFields: ["APP_NAME": "MY_APP_NAME"])
            
            // 请求头添加认证令牌
//            guard let target = target as? MealPlanServiceTypeAPIEnum else { return defaultEndpoint }
//            switch target {
//            case .authenticate:
//                return defaultEndpoint
//            default:
//                return defaultEndpoint.adding(newHTTPHeaderFields: ["token": "token1"])
//            }
        }
    }
    
    /// Endpoint -> URLRequest
    static func requestClosure() -> MoyaProvider<APITarget>.RequestClosure {
        return {
            (endpoint, closure) in
            do {
                var request = try endpoint.urlRequest()
                // Modify the request however you like before send the request.
                
                // 禁用所有请求的cookie: false
                request.httpShouldHandleCookies = true
                // 请求超时时间
                request.timeoutInterval = HKServiceConfig.shared.timeoutInterval
                // 网络请求的日志输出...
                // OAuth签名等权限认证...
                
                closure(Result.success(request))
            } catch let error {
                closure(Result.failure(MoyaError.underlying(error, nil)))
            }
        }
        
    }
    
}

// MARK: - request方法封装
/**
 /// 方法描述
 /// - Parameter parameter1: target
 /// - Parameter parameter2: modelType
 /// - Parameter parameter3: successBlock
 /// - Parameter parameter4: failureBlock
 /// - Returns: Cancellable?
 */
extension HKServiceProvider {
    /// (json) = [code: , msg: , data:]
    public func requestWithJson(_ target: APITarget, success: @escaping SuccessJsonBlock, failure: @escaping FailureBlock) -> Cancellable? {
        let cancellable = moyaProvider.request(target) { result in
            // 过滤响应是否成功
            switch result {
            case .success(let response):
                do {
                    // 过滤返回状态码statusCode
                    let json = try response
                        .filterSuccessfulStatusCodes()
                        .mapJSON() as? [String: Any]
                    // 判断是否有响应体
                    if let json = json {
                        success(json)
                    } else {
                        failure(NetworkError.NoResponseError)
                    }
                } catch {
                    // 异常捕获
                    failure(NetworkError.ParseJSONError)
                }
                
                break
            case .failure(_): // 不需要MoyaError类型的错误
                failure(NetworkError.RequestFailedError)
                break
            }
        }
        return cancellable
    }
    
    /// (code, msg, data, jsonString)
    public func requestWithData(_ target: APITarget, success: @escaping SuccessDataBlock, failure: @escaping FailureBlock) -> Cancellable? {
        // 解析json
        let cancellable = self.requestWithJson(target) { json in
            if let json = json {
                guard let code = json[RESULT_CODE_KEY] as? Int else {
                    failure(NetworkError.ParseCodeError)
                    return
                }
                let msg = json[RESULT_MSG_KEY] as? String
                if code != 0 {
                    failure(NetworkError.UnExpectedResult(resultCode: code, resultMsg: msg))
                }
                
                let data = json[RESULT_DATA_KEY]
                let jsonString = json.toJsonString()
                success(code, msg, data, jsonString)
            }
            
        } failure: { error in
            failure(error)
        }
        
        return cancellable
    }
    
    /// (code, msg, model, jsonString)
    public func requestWithModel<ModelType :HandyJSON>(_ target: APITarget, modelType: ModelType.Type, success: @escaping SuccessModelBlock<ModelType>, failure: @escaping FailureBlock) -> Cancellable? {
        let cancellable = self.requestWithData(target) { code, msg, data, jsonString in
            // 反序列化
            let dataDict = data as? [String: Any]
            let model = JSONDeserializer<ModelType>.deserializeFrom(dict: dataDict)
            success(code, msg, model, jsonString)
        } failure: { error in
            failure(error)
        }
        return cancellable
    }
    
    /// (code, msg, [model], jsonString)
    public func requestWithModelList<ModelType :HandyJSON>(_ target: APITarget, modelType: ModelType.Type, success: @escaping SuccessListModelBlock<ModelType>, failure: @escaping FailureBlock) -> Cancellable? {
        let cancellable = self.requestWithData(target) { code, msg, data, jsonString in
            // 反序列化
            let dataArray = data as? [Any]
            let modelArray = JSONDeserializer<ModelType>.deserializeModelArrayFrom(array: dataArray)
            success(code, msg, modelArray, jsonString)
        } failure: { error in
            failure(error)
        }
        
        return cancellable
    }
}

// MARK: - Request(Result<>)方法封装
extension HKServiceProvider {
    
    /// .success(code, msg, data, jsonString)
    public func requestWithResultData(_ target: APITarget, completion: @escaping CompletionResultJsonBlock) -> Cancellable? {
        let cancellable = self.requestWithJson(target) { json in
            if let json = json {
                guard let code = json[RESULT_CODE_KEY] as? Int else {
                    completion(.failure(NetworkError.ParseCodeError))
                    return
                }
                let msg = json[RESULT_MSG_KEY] as? String
                if code != 0 {
                    completion(.failure(NetworkError.UnExpectedResult(resultCode: code, resultMsg: msg)))
                }
                
                let data = json[RESULT_DATA_KEY]
                let jsonString = json.toJsonString()
                completion(.success((code, msg, data, jsonString)))
            }
        } failure: { error in
            completion(.failure(error))
        }
        
        return cancellable
    }
    
    /// .success(code, msg, model, jsonString)
    public func requestWithResultModel<ModelType: HandyJSON>(_ target: APITarget, type: ModelType.Type, completion: @escaping CompletionResultModelBlock<ModelType>) -> Cancellable? {
        let cancellable = self.requestWithResultData(target) { result in
            switch result {
            case let .success((code, msg, data, jsonString)):
                // 反序列化
                let dataDict = data as? [String: Any]
                let model = JSONDeserializer<ModelType>.deserializeFrom(dict: dataDict)
                completion(.success((code, msg, model, jsonString)))
                break
            case let .failure(error):
                completion(.failure(error))
                break
            }
        }
        
        return cancellable
    }
    
    /// .success(code, msg, [model], jsonString)
    public func requestWithResultModelList<ModelType: HandyJSON>(_ target: APITarget, type: ModelType.Type, completion: @escaping CompletionResultModelListBlock<ModelType>) -> Cancellable? {
        let cancellable = self.requestWithResultData(target) { result in
            switch result {
            case let .success((code, msg, data, jsonString)):
                let dataArray = data as? [Any]
                let modelArray = JSONDeserializer<ModelType>.deserializeModelArrayFrom(array: dataArray)
                completion(.success((code, msg, modelArray, jsonString)))
                break
            case let .failure(error):
                completion(.failure(error))
                break
            }
        }
        
        return cancellable
    }
    
}
