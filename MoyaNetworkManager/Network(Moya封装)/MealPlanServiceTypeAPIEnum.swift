//
//  MealPlanServiceTypeAPIEnum.swift
//  UIProject
//
//  Created by nge0131 on 2023/4/8.
//

import Foundation
import Moya

// MARK: - 具体应用的API接口，不同类别区分创建新的Enum，都继承HKServiceType
enum MealPlanServiceTypeAPIEnum {
    /*
     应用自定义修改API接口
     */
    case authenticate(authKey: String)
    
    case mealPlanByDay(day: String)
    
    /// 食谱查询
    /// null查询所有;食谱时间类型:(1:afternoon snack ; 2:breakfast ; 3:dinner ; 4:lunch ; 5:morning snack)
    case lookUpRecipes(foodTypeId: String? = nil, size: String? = nil, currentPage: String? = nil)
    
    case selectMonthRecipeByDay(day: String)
    
    /// 测试接口
    case testApi
    
}

extension MealPlanServiceTypeAPIEnum: HKServiceType {
    
    var apiDescription: String? {
        switch self {
        case .authenticate:
            return "身份验证"
        case .mealPlanByDay:
            return "每日食谱"
        case .lookUpRecipes:
            return "食物分类查询"
        case .selectMonthRecipeByDay:
            return "往后30天食谱"
        case .testApi:
            return "测试接口"
        }
    }
    
    var path: String {
        var url = ""
        switch self {
        case .authenticate:
            url = "ringme/gitfit/gitFitRecipe/auth"
        case .mealPlanByDay:
            url = "ringme/gitfit/gitFitRecipe/selectByDay"
            break
        case .lookUpRecipes:
            url = "ringme/gitfit/gitFitRecipe/data"
            break
        case .selectMonthRecipeByDay:
            url = "ringme/gitfit/gitFitRecipe/selectMonthRecipeByDay"
            break
        case .testApi:
            url = "testApi/test"
        }
        return url + "/\(HKServiceConfig.shared.packageKey)"
    }
    
    /// 接口参数
    var parameters: [String : Any]? {
        switch self {
        case .authenticate(authKey: let authKey):
            return ["auth_key": authKey]
        case .mealPlanByDay(day: let day):
            return ["day": day]
        case .lookUpRecipes(let foodTypeId, let size, let currentPage):
            return ["foodTypeId": foodTypeId ?? "", "size": size ?? "", "currentPage": currentPage ?? ""]
        case .selectMonthRecipeByDay(day: let day):
            return ["day": day]
        case .testApi:
            return nil
        }
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
    
    
}
