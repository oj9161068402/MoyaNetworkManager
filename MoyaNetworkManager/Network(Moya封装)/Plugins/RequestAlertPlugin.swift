//
//  RequestAlertPlugin.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/12.
//

import Foundation
import Moya

// MARK: - 弹出框展示请求和响应情况
/**
 我们想把网络活动通知给用户，那么当请求被发送时，我们将显示携有关于请求的基本信息的提示框，并且当一个响应表明这个请求失败时让用户知道
 */
public final class RequestAlertPlugin: PluginType {
    private let viewController: UIViewController
    
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func willSend(_ request: RequestType, target: TargetType) {
        guard let requestURLStr = request.request?.url?.absoluteString else { return }
        
        let alertVC = UIAlertController(title: "sending request", message: requestURLStr, preferredStyle: UIAlertController.Style.alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
        
        viewController.present(alertVC, animated: true)
    }
    
    /// 响应请求失败
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case .failure(let error):
            let alertVC = UIAlertController(title: "error", message: "Request failed with status code: \(error.response?.statusCode ?? -1)", preferredStyle: UIAlertController.Style.alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            
            viewController.present(alertVC, animated: true)
            return
        case .success(_):
            return
        }
    }
}
