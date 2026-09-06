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

        
//        requestCityStation_a()
        requestCityStation_c()

        
    }
    
        func requestCityStation_a() {
    
            guard let url = URL(string: "https://airkoon.cn/eebusApi/tripSchedule/getTripScheduleListByStationOperation") else {
                return
            }
    
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
    
            let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTYwLCJvcmciOjAsInJvbGUiOiIiLCJVc2VybmFtZSI6IuWRqOWHryIsIlJlYWxOYW1lIjoiIiwiQXV0aG9yaXR5SWQiOjAsImF1dGhvcml0eUlkcyI6WzgsNV0sIklEIjoxNjAsIlVVSUQiOiI2YmY1NDU3NC0wYjI1LTQ2MzUtOTYyYS04NzZhNTc2OTAxZGEiLCJCdWZmZXJUaW1lIjo2MDQ4MDAsImlzcyI6ImFpcmtvb24iLCJhdWQiOlsiRUVCVVMiXSwiZXhwIjoxNzkxMDgyNzIyLCJuYmYiOjE3ODg0OTA3MjJ9.WLxMLVE9bW8aU9A0NKk52gqZ1M7DHe8eIoYtprMVECI"
    
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(token, forHTTPHeaderField: "Authorization")
    
            // POST 参数
            let params: [String: Any] = [
                "date": "2026-09-05",
                "stationId": 15
            ]
    
            // 转成 JSON
            do {
                request.httpBody = try JSONSerialization.data(
                    withJSONObject: params,
                    options: []
                )
            } catch {
                print("JSON 参数转换失败：\(error)")
                return
            }
    
            let session = URLSession(configuration: .default)
    
            session.dataTask(with: request) { data, response, error in
    
                if let error = error {
                    print("请求失败：\(error)")
                    return
                }
    
                if let response = response as? HTTPURLResponse {
                    print("HTTP 状态码：\(response.statusCode)")
                }
    
                guard let data = data else {
                    print("没有返回数据")
                    return
                }
    
                if let jsonString = String(data: data, encoding: .utf8) {
                    //print("返回数据：\(jsonString)")
                }
    
            }.resume()
        }
    
    func requestCityStation_c(){

        guard let url = URL(string: "https://airkoon.cn/eebusApi/tripSchedule/getTripScheduleListByStationOperation") else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

        let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTYwLCJvcmciOjAsInJvbGUiOiIiLCJVc2VybmFtZSI6IuWRqOWHryIsIlJlYWxOYW1lIjoiIiwiQXV0aG9yaXR5SWQiOjAsImF1dGhvcml0eUlkcyI6WzgsNV0sIklEIjoxNjAsIlVVSUQiOiI2YmY1NDU3NC0wYjI1LTQ2MzUtOTYyYS04NzZhNTc2OTAxZGEiLCJCdWZmZXJUaW1lIjo2MDQ4MDAsImlzcyI6ImFpcmtvb24iLCJhdWQiOlsiRUVCVVMiXSwiZXhwIjoxNzkxMDgyNzIyLCJuYmYiOjE3ODg0OTA3MjJ9.WLxMLVE9bW8aU9A0NKk52gqZ1M7DHe8eIoYtprMVECI"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        request.setValue(
            token,
            forHTTPHeaderField: "Authorization"
        )

        let params: [String: Any] = [
            "date": "2026-09-05",
            "stationId": 15
        ]

        do {

            request.httpBody = try JSONSerialization.data(
                withJSONObject: params,
                options: []
            )

        } catch {

            print("JSON 参数转换失败：\(error)")
            return
        }

        URLSession.shared.dataTask(
            with: request
        ) { data, response, error in

            if let error {
                print("请求失败：\(error)")
                return
            }

            if let response = response as? HTTPURLResponse {
                print("HTTP 状态码：\(response.statusCode)")
            }

            guard let data else {
                print("没有返回数据")
                return
            }

            if let jsonString = String(
                data: data,
                encoding: .utf8
            ) {
                //print("返回数据：\(jsonString)")
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

