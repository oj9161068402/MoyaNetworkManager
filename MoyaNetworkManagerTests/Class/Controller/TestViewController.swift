//
//  TestViewController.swift
//  MoyaNetworkManagerTests
//
//  Created by nge0131 on 2023/4/18.
//

import UIKit

// MARK: - 网络请求测试
class TestViewController: UIViewController {
    
    // MARK: - model
    var testModel: TestModel? {
        didSet {
            // view...
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        requestTestModel()
        
        requestResultTestModel()
        
    }
    
    /// 测试样例：model
    func requestTestModel() {
        let provider = HKServiceProvider<MealPlanServiceTypeAPIEnum>.init()
        provider.requestWithModel(MealPlanServiceTypeAPIEnum.testApi, modelType: TestModel.self) { [weak self] (code, msg, model, jsonStr) in
            guard let self = self else { return }
            
            // 数据赋值
            self.testModel = model
        } failure: { error in
            print("\(error)")
        }
        
    }
    
    /// 测试样例：Result<>.model
    func requestResultTestModel() {
        let provider = HKServiceProvider<MealPlanServiceTypeAPIEnum>.init()
        provider.requestWithResultModel(MealPlanServiceTypeAPIEnum.testApi, type: TestModel.self) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (code, msg, model, jsonString)):
                
                // 数据赋值
                self.testModel = model
                break
            case .failure(let error):
                print("\(error)")
                break
            }
        }
        
    }

}
