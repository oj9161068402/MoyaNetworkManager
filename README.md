# MoyaNetworkManager
对Moya框架的二次封装，容易使用，同时也可以自定义配置

![image-20230418155953500](/Users/nge0131/Library/Application Support/typora-user-images/image-20230418155953500.png)

## 使用

### 两种类型使用样例，以请求返回Model实例为例

#### 	1.requestWithModel -> (code, msg, model, jsonString):

```swift
    /// 测试样例：model
    func requestTestModel() {
        let provider = HKServiceProvider<MealPlanServiceTypeAPIEnum>.init()
        let cancellable = provider.requestWithModel(MealPlanServiceTypeAPIEnum.testApi, modelType: TestModel.self) { [weak self] (code, msg, model, jsonStr) in
            guard let self = self else { return }
            
            // 数据赋值
            self.testModel = model
        } failure: { error in
            print("\(error)")
        }

        if !cancellable.isCancelled {
            cancellable.cancel()
        }
    }
```



#### 	2.requestWithResultModel ->Result<>.success((code, msg, model, jsonString)):

```swift
    /// 测试样例：Result<>.model
    func requestResultTestModel() {
        let provider = HKServiceProvider<MealPlanServiceTypeAPIEnum>.init()
        let cancellable = provider.requestWithResultModel(MealPlanServiceTypeAPIEnum.testApi, type: TestModel.self) { [weak self] result in
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
        
        if !cancellable.isCancelled {
            cancellable.cancel()
        }
    }
```

## 说明

RING_CryptoUtils模块：对网络请求返回的响应数据response.data加密

## 参考

Moya:					https://github.com/Moya/Moya

moyaManager:	  https://github.com/chensx1993/moyaManager
