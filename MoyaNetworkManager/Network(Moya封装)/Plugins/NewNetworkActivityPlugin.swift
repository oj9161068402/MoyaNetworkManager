//
//  NewNetworkActivityPlugin.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/12.
//

import Foundation
import Moya

// MARK: - New NetworkActivityPlugin
public final class NewNetworkActivityPlugin: PluginType {
    
    public typealias NetworkActivityClosure = (_ change: NetworkActivityChangeType, _ target: HKServiceType) -> Void
    let networkActivityClosure: NetworkActivityClosure
    
    /// Initializes a NetworkActivityPlugin.
    public init(networkActivityClosure: @escaping NetworkActivityClosure) {
        self.networkActivityClosure = networkActivityClosure
    }
    
    /// Called by the provider as soon as the request is about to start
    public func willSend(_ request: RequestType, target: HKServiceType) {
        networkActivityClosure(.began, target)
    }
    
    /// Called by the provider as soon as a response arrives, even if the request is canceled.
    public func didReceive(_ result: Result<Response, MoyaError>, target: HKServiceType) {
        networkActivityClosure(.ended, target)
    }
}
