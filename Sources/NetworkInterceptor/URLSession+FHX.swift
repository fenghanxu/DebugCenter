//
//  URLSession+FHX.swift
//  DebugCenter
//
//  Created by fenghanxu on 2026/9/7.
//

import Foundation

extension URLSession {

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

            let cost =
                Date().timeIntervalSince(
                    startTime
                )

            let realTask =
                task

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

            let statusCode =
                (
                    response
                    as? HTTPURLResponse
                )?.statusCode ?? 0

            let headers =
                self.redactedHeaders(
                    finalRequest
                        .allHTTPHeaderFields
                    ?? [:]
                )

            print(
                """
                ========= DebugCenter ================

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
                """
            )

            let log =
                """
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

        print(
            """
            🔥 FHX dataTask(with:) 命中:
            \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")
            """
        )

        let task =
            fhx_dataTask(
                with: request
            )

        // 保存 Request
        objc_setAssociatedObject(
            task,
            &FHXRequestKey,
            request,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        // 保存 HTTP Body
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
