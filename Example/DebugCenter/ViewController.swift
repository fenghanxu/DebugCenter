//
//  ViewController.swift
//  DebugCenter
//
//  Created by fenghanxu on 08/12/2026.
//  Copyright (c) 2026 fenghanxu. All rights reserved.
//

import UIKit
import DebugCenter

class ViewController: UIViewController {
    
    private var logTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        FHXSandboxTestImporter.importTestFiles()
        
        // 1.(主推方法) 打印不同类型的数据 + 支持不同的错误类型
        // 基础日志
        // 字符串
        FHXLog.shared.log("字符串", .debug)
        
        // 网络日志
        let jsonData = """
                    {
                    "success": true,
                    "message": "處理成功",
                    "code": 0
                    }
                    """
        let responseObject: Data = jsonData.data(using: .utf8)!
        FHXLog.shared.log(responseObject, .debug)
        
        // 数组
        FHXLog.shared.log([1, 2, 3], .debug)
        
        // 字典
        FHXLog.shared.log(["key" : "key_1", "value" : "value_1"], .debug)
        
        // json
        let json = """
                    {
                    "success": true,
                    "message": "處理成功",
                    "code": 0
                    }
                    """
        FHXLog.shared.log(json, .debug)

        // 1. (保留方法写法)基础日志
        FHXLog.shared.debug("登录成功")
        
        // (保留方法写法)警告日志
        FHXLog.shared.warning("支付失败")
        
        // (保留方法写法)错误日志
        FHXLog.shared.error("支付失败")
        
        let json_1 = """
                    {
                    "success": true,
                    "message": "處理成功",
                    "code": 0,
                    "data": {
                        "poiCount": 6,
                        "poiList": [
                            {
                                "poiId": "B0LRFZ6R7T",
                                "name": "品至佛跳墙(正佳广场店)",
                                "address": "天河路228号正佳广场B1层(体育中心地铁站出入口旁)",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            },
                            {
                                "poiId": "B0LDVS0O5H",
                                "name": "希沃品牌旗舰店(正佳广场店)",
                                "address": "正佳广场5楼儿童区5D124",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            },
                            {
                                "poiId": "B0K3ZUGDSS",
                                "name": "焗姥爷(正佳广场店)",
                                "address": "正佳广场负一楼焗姥爷",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            },
                            {
                                "poiId": "B0K2AH0NBT",
                                "name": "老韩煸鸡·中国炸鸡(正佳广场店)",
                                "address": "天河路228号正佳商业广场负一层",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            },
                            {
                                "poiId": "B0J6GGEVJP",
                                "name": "西安小吃(正佳广场店)",
                                "address": "天河路228号正佳广场M层",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            },
                            {
                                "poiId": "B0J33OYILC",
                                "name": "阳九铃牛腩饭(正佳广场店)",
                                "address": "天河路228号正佳广场B1层(体育中心地铁站出入口旁)",
                                "location": "113.327019,23.132145",
                                "cityCode": "020",
                                "cityName": "廣州",
                                "cityId": 36
                            }
                        ]
                    }
                }
                """
        // (保留方法写法)网络日志
        FHXLog.shared.network(json_1)



        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now()+1.0) {
            DispatchQueue.main.async {
                let vc = FHXLogViewController()
                self.navigationController?.pushViewController(vc, animated: true)
//                self.present(vc, animated: true)
            }
        }
        
//        startAddMessage()
        

        
        FHXDebugKit.start()
        
        requestCityStation_a()
//        requestCityStation_b()
    }
    
    func requestCityStation_a() {

        guard let url = URL(string: "https://eetest.cpolar.cn/api/cityStation/getAllCitiesWithStations") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTU4LCJvcmciOjAsInJvbGUiOiIiLCJVc2VybmFtZSI6IuWRqOS5nyIsIlJlYWxOYW1lIjoiIiwiQXV0aG9yaXR5SWQiOjAsImF1dGhvcml0eUlkcyI6WzgsNV0sIklEIjoxNTgsIlVVSUQiOiIxZTBhNjllYi00OTcxLTRmMjctODExZS03Y2Y0NWM0YWIwM2MiLCJCdWZmZXJUaW1lIjo2MDQ4MDAsImlzcyI6ImFpcmtvb24iLCJhdWQiOlsiRUVCVVMiXSwiZXhwIjoxNzg4MDcxODgzLCJuYmYiOjE3ODU0Nzk4ODN9.K3lnevIrsJ4aufb6pctzSgNTNABrxsXwaGb0dT1xk48"

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(token, forHTTPHeaderField: "Authorization")

        // 自己创建 Configuration
        let config = URLSessionConfiguration.default

        print("Before =", config.protocolClasses ?? [])

        // 直接手动注入
        config.protocolClasses = [FHXURLProtocol.self] + (config.protocolClasses ?? [])

        print("After =", config.protocolClasses ?? [])

        let session = URLSession(configuration: config)

        session.dataTask(with: request) { data, response, error in

            print("业务收到回调")

        }.resume()
    }
    

    func requestCityStation_b() {
        
        guard let url = URL(string: "https://eetest.cpolar.cn/api/cityStation/getAllCitiesWithStations") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Header
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NjAsIm9yZyI6MCwicm9sZSI6IiIsIlVzZXJuYW1lIjoi5byg5piOIiwiUmVhbE5hbWUiOiIiLCJBdXRob3JpdHlJZCI6MCwiYXV0aG9yaXR5SWRzIjpbNSw4XSwiSUQiOjYwLCJVVUlEIjoiYzUzM2NkZWEtYzg5ZS00MjFmLThmNTItMWQyNTI4YzM3YjMwIiwiQnVmZmVyVGltZSI6NjA0ODAwLCJpc3MiOiJhaXJrb29uIiwiYXVkIjpbIkdWQSJdLCJleHAiOjE3ODU2MzU0OTEsIm5iZiI6MTc4MzA0MzQ5MX0.F-eMmVLuw4Ww3s9KwqckpGA5UsD66s5M1EgUSxb9aTc"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                print("请求失败：\(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("返回数据为空")
                return
            }
            
            // 原始字符串
            if let jsonString = String(data: data, encoding: .utf8) {
                //print("原始返回：")
                //print(jsonString)
            }
            
            // 格式化 JSON 输出
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                
                let prettyData = try JSONSerialization.data(
                    withJSONObject: jsonObject,
                    options: [.prettyPrinted]
                )
                
                if let prettyJson = String(data: prettyData, encoding: .utf8) {
                    //print("格式化JSON：")
//                    print(prettyJson)
                }
                
            } catch {
                print("JSON解析失败：\(error)")
            }
            
        }.resume()
    }
    
    func startAddMessage() {
        logTimer?.invalidate()

        logTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in

            let json = """
            {
                "success": true,
                "message": "處理成功",
                "code": 0
            }
            """

            FHXLog.shared.log(json, .debug)
        }
    }

    func stopAddMessage() {
        logTimer?.invalidate()
        logTimer = nil
    }
 
}






