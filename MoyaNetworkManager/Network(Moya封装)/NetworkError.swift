//
//  NetworkError.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/11.
//

import Foundation

// MARK: - 自定义网络请求异常
enum NetworkError: Swift.Error {
    /// 解析json失败
    case ParseJSONError
    /// 解析Code失败
    case ParseCodeError
    /// 网络请求发生错误
    case RequestFailedError
    /// 接收到的返回体response为空
    case NoResponseError
    /// 返回错误代码
    case UnExpectedResult(resultCode: Int?, resultMsg: String?)
    
    func code() -> Int {
        switch self {
        case .ParseJSONError:
            return -1
        case .ParseCodeError:
            return -1
        case .RequestFailedError:
            return -1
        case .NoResponseError:
            return -1
        case .UnExpectedResult(resultCode: let code, resultMsg: _):
            return code ?? -1
        }
    }
    
    func stringMsg() -> String {
        switch self {
        case .ParseJSONError:
            return "解析json出错"
        case .ParseCodeError:
            return "code码不为1"
        case .RequestFailedError:
            return "暂时无网络,请稍后重试"
        case .NoResponseError:
            return "服务器response没有响应数据"
        case .UnExpectedResult(resultCode: _, resultMsg: let msg):
            if msg != nil {
                return msg!
            }else{
                return "没有返回具体的错误"
            }
        }
    }
}
