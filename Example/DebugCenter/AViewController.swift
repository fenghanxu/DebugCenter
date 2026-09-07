//
//  AViewController.swift
//  DebugCenter_Example
//
//  Created by imac on 2026/8/30.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import DebugCenter

class AViewController: UIViewController {

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
        
    }
    


}
