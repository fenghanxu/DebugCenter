


// 业务代码收到数据之前，先偷偷执行一遍自己的代码。
/**
 这里实际上就是：把原来的 completionHandler，包了一层。
 
 例如：原来：
 
 服务器返回
 ↓
 业务 completion
 
 现在：
 
 服务器返回
 ↓
 你的 wrappedCompletion
 ↓
 打印
 ↓
 保存
 ↓
 统计
 ↓
 业务 completion
 
 */

import Foundation
import ObjectiveC.runtime

final class FHXCompletionSwizzle {

    static func start() {

        let cls: AnyClass = URLSession.self

        let selector1 = NSSelectorFromString("dataTaskWithRequest:completionHandler:")

        let selector2 = #selector(URLSession.fhx_dataTask(with:completionHandler:))

        guard let original = class_getInstanceMethod(cls, selector1),
              let swizzled = class_getInstanceMethod(cls, selector2)
        else {
            print("Completion Swizzle Fail")
            return
        }

        method_exchangeImplementations(original, swizzled)

        print("Completion Swizzle Success")
    }
}

extension URLSession {

    @objc
    func fhx_dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        /// 记录创建 Task 的时间
        let startTime = Date()

        let wrappedCompletion:(Data?, URLResponse?, Error?) -> Void = {data, response, error in

            // 得到请求需要的耗时
            let cost = Date().timeIntervalSince(startTime)

            /// 获取错误吗
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            /// 把服务器返回的数据：data 转换成  json字符串
            let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""

            /// 读取请求参数
            let parameter = request.httpBody.flatMap {String( data: $0, encoding: .utf8)} ?? ""
            
            
            let log = """
            Method : \(request.httpMethod ?? "GET")
            URL : \(request.url?.absoluteString ?? "")
            StatusCode : \(statusCode)
            CostTime : \(Int(cost * 1000)) ms
            Headers :
            \(prettyJSON(request.allHTTPHeaderFields ?? [:]))
            
            Parameters :
            \(prettyJSONString(parameter))
            
            Response :
            \(prettyJSONString(responseString))
            
            Error :
            \(error?.localizedDescription ?? "nil")
            """

            FHXLog.shared.log(log, .network)

            /// 打印日志
            print("""

            =========================
            
            方法的替换打印数据：

            Method \(request.httpMethod ?? "GET")

            URL \(request.url?.absoluteString ?? "")

            Header \(prettyJSON(request.allHTTPHeaderFields ?? [:]))

            Parameter \(prettyJSONString(parameter))

            Response \(prettyJSONString(responseString))

            StatusCode \(statusCode)

            CostTime \(Int(cost * 1000))ms
            
            Error
            \(error?.localizedDescription ?? "nil")

            =========================

            """)

            /// 干完自己想干的事情之后，让接口返回数据
            completionHandler(data, response, error)
        }

        return fhx_dataTask(with: request, completionHandler: wrappedCompletion)
    }
}
