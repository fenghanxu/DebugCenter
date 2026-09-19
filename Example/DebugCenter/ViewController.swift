//
//  ViewController.swift
//  DebugCenter
//
//  Created by fenghanxu on 08/12/2026.
//  Copyright (c) 2026 fenghanxu. All rights reserved.
//

import UIKit
import DebugCenter
import Alamofire

class ViewController: UIViewController {
    
    private var logTimer: Timer?
    
    private let token = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTI2LCJvcmciOjAsInJvbGUiOiIiLCJVc2VybmFtZSI6IumDreWBpSIsIlJlYWxOYW1lIjoiIiwiQXV0aG9yaXR5SWQiOjAsImF1dGhvcml0eUlkcyI6WzE3LDJdLCJJRCI6MTI2LCJVVUlEIjoiMThlMWJlZmMtOTI4NS00NzdkLWEwNDItZjE4ZDViZDhkZWEzIiwiQnVmZmVyVGltZSI6NjA0ODAwLCJpc3MiOiJhaXJrb29uIiwiYXVkIjpbIkVFQlVTIl0sImV4cCI6MTc5MjM4NjE4NiwibmJmIjoxNzg5Nzk0MTg2fQ.hsBfdyAxU7ADXa1bQF3StYNGt5jt-HZsQuu0UNO2mQs"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        URLSession_data_Task_with()
        URLSession_shared_dataTask()
//        Alamofire()
        
    }
    
        func URLSession_data_Task_with() {
    
            guard let url = URL(string: "https://airkoon.cn/eebusApi/tripSchedule/getTripScheduleListByStationOperation") else {
                return
            }
    
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
    
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
    
    func URLSession_shared_dataTask(){

        guard let url = URL(string: "https://airkoon.cn/eebusApi/tripSchedule/getTripScheduleListByStationOperation") else {
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "POST"

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

    func Alamofire() {

        let url = "https://airkoon.cn/eebusApi/tripSchedule/getTripScheduleListByStationOperation"

        let params: [String: Any] = [
            "date": "2026-09-05",
            "stationId": 15
        ]

        let headers: HTTPHeaders = [
            .contentType("application/json"),
            .accept("application/json"),
            .authorization(token)
        ]

        AF.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: headers
        )
        .validate()
        .responseData { response in

            switch response.result {

            case .success(let data):

                if let jsonString = String(data: data, encoding: .utf8) {
                    print("返回数据：\(jsonString)")
                }

            case .failure(let error):

                print("请求失败：\(error)")
            }

            if let statusCode = response.response?.statusCode {
                print("HTTP 状态码：\(statusCode)")
            }
        }
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

