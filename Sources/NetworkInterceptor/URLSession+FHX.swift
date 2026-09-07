import Foundation
import ObjectiveC.runtime

extension URLSession {

    // MARK: - Network Log Queue

    private static let fhxLogQueue = DispatchQueue(
        label: "com.fenghanxu.DebugCenter.URLSessionLog",
        qos: .utility
    )

    // MARK: - dataTask(with:completionHandler:)

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

        let wrappedCompletion:
        (
            Data?,
            URLResponse?,
            Error?
        ) -> Void = {
            data,
            response,
            error in

            let realTask = task

            let finalRequest =
                realTask?.fhx_request
                ?? realTask?.currentRequest
                ?? realTask?.originalRequest
                ?? request

            let parameterData =
                realTask?.fhx_requestBodyData
                ?? finalRequest.httpBody

            let headers =
                self.redactedHeaders(
                    finalRequest.allHTTPHeaderFields
                    ?? [:]
                )

            let cost =
                Int(
                    Date()
                        .timeIntervalSince(startTime)
                    * 1000
                )

            let statusCode =
                (
                    response
                    as? HTTPURLResponse
                )?.statusCode ?? 0

            /*
             关键：

             先把 App 的 completionHandler 执行掉。

             不要在这里：
             - String(data:)
             - prettyJSON
             - prettyJSONString
             - FHXLog.shared.log
             */

            completionHandler(
                data,
                response,
                error
            )

            /*
             后面的所有 DebugCenter 日志处理
             全部放到后台队列。
             */

            let parameter =
                parameterData.flatMap {
                    String(
                        data: $0,
                        encoding: .utf8
                    )
                } ?? ""

            let responseData =
                data ?? Data()

            let logRequest =
                finalRequest

            let logError =
                error

            FHXURLSessionLogQueue.shared.async {

                let responseString =
                    String(
                        data: responseData,
                        encoding: .utf8
                    ) ?? ""

                let log =
                    """
                    Method : \(logRequest.httpMethod ?? "GET")
                    URL : \(logRequest.url?.absoluteString ?? "")
                    StatusCode : \(statusCode)
                    CostTime : \(cost) ms
                    Error : \(logError?.localizedDescription ?? "nil")
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
            }
        }

        task =
            fhx_dataTask(
                with: request,
                completionHandler:
                    wrappedCompletion
            )

        if let task {

            objc_setAssociatedObject(
                task,
                &FHXCompletionHandlerKey,
                true,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        return task!
    }

    // MARK: - dataTask(with:)

    @objc
    func fhx_dataTask(
        with request: URLRequest
    ) -> URLSessionDataTask {

        let task =
            fhx_dataTask(
                with: request
            )

        objc_setAssociatedObject(
            task,
            &FHXRequestKey,
            request,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        if let bodyData =
            request.httpBody {

            objc_setAssociatedObject(
                task,
                &FHXRequestBodyKey,
                bodyData,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        return task
    }

    // MARK: - Redacted Headers

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

                result[key] =
                    "***REDACTED***"
            }
        }

        return result
    }
}

// MARK: - FHXURLSessionLogQueue

final class FHXURLSessionLogQueue {

    static let shared =
        DispatchQueue(
            label: "com.fenghanxu.DebugCenter.URLSessionLog",
            qos: .utility
        )

    private init() {}
}
