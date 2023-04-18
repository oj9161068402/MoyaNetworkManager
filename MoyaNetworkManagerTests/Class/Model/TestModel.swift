//
//  TestModel.swift
//  MoyaNetworkManagerTests
//
//  Created by nge0131 on 2023/4/18.
//

import UIKit
import HandyJSON

class BaseModel: HandyJSON{
    required init() {}
}

class TestModel: BaseModel {
    var id: String = ""
    
    var value1: String?
    
    var value2: Int?
    
    var value3: [String?]?
    
    var value4: Bool = false
}
