


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

        let originalSelector = NSSelectorFromString("dataTaskWithRequest:completionHandler:")

        let swizzledSelector =
            #selector(
                URLSession.fhx_dataTask(
                    with:completionHandler:
                )
            )

        guard
            let original = class_getInstanceMethod(
                cls,
                originalSelector
            ),
            let swizzled = class_getInstanceMethod(
                cls,
                swizzledSelector
            )
        else {
            return
        }

        method_exchangeImplementations(
            original,
            swizzled
        )
    }
}

// MARK: - URLSession

extension URLSession {

    @objc
    func fhx_dataTask(
        with request: URLRequest,
        completionHandler: @escaping (
            Data?,
            URLResponse?,
            Error?
        ) -> Void
    ) -> URLSessionDataTask {

        let startTime = Date()

        var task: URLSessionDataTask?

        let wrappedCompletion:(Data?, URLResponse?, Error?) -> Void = { data, response, error in

            let cost = Date().timeIntervalSince(startTime)

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

            let realTask = task

            let finalRequest =
                realTask?.fhx_request
                ?? realTask?.currentRequest
                ?? realTask?.originalRequest
                ?? request

            let parameterData =
                realTask?.fhx_requestBodyData
                ?? finalRequest.httpBody

            let parameter =
                parameterData.flatMap {
                    String(
                        data: $0,
                        encoding: .utf8
                    )
                } ?? ""

            let responseString =
                String(
                    data: data ?? Data(),
                    encoding: .utf8
                ) ?? ""

            let headers = self.redactedHeaders(finalRequest.allHTTPHeaderFields ?? [:])

            print("""
            
            =========  DebugCenter  ================
            
            StatusCode: \(statusCode)

            CostTime: \(Int(cost * 1000))ms

            Error: \(error?.localizedDescription ?? "nil")

            Method: \(finalRequest.httpMethod ?? "GET")

            URL: \(finalRequest.url?.absoluteString ?? "")

            Header:
            \(prettyJSON(headers))
            
            Parameter:
            \(prettyJSONString(parameter))

            Response:
            \(prettyJSONString(responseString))
            =========================
            """)

            // =====================================================
            // 保存日志
            // =====================================================

            let log = """
            Method : \(finalRequest.httpMethod ?? "GET")
            URL : \(finalRequest.url?.absoluteString ?? "")
            StatusCode : \(statusCode)
            CostTime : \(Int(cost * 1000)) ms
            Error : \(error?.localizedDescription ?? "nil")
            Headers :
            \(prettyJSON(headers))
            Parameters :
            \(prettyJSONString(parameter))
            Response :
            \(prettyJSONString(responseString))
            """

            FHXLog.shared.log(
                log,
                .network
            )

            completionHandler(
                data,
                response,
                error
            )
        }

        task = fhx_dataTask(
            with: request,
            completionHandler: wrappedCompletion
        )

        return task!
    }
    
    func redactedHeaders(
        _ headers: [String: String]
    ) -> [String: String] {

        var result = headers

        for key in result.keys {

            let lowerKey =
                key.lowercased()

            if lowerKey == "authorization" ||
                lowerKey == "cookie" ||
                lowerKey == "set-cookie" {

                result[key] = "***REDACTED***"
            }
        }

        return result
    }
}
