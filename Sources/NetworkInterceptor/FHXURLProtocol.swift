//
//  FHXURLProtocol.swift
//  DebugCenter
//
//  Created by fenghanxu on 2026/9/8.
//

import Foundation

public final class FHXURLProtocol: URLProtocol {

    // MARK: - Property

    private var startTime: Date?

    /// 保存原始 Request Body
    private var requestBodyData: Data?
    
    /// 保存完整 Response Body
    private var responseData = Data()

    /// 真正执行请求的 Session
    private var realSession: URLSession?

    /// 真正执行请求的 Task
    private var realTask: URLSessionDataTask?

    /// 防止请求完成后 stopLoading 再次取消
    private var isFinished = false

    /// 防止 FHXURLProtocol 无限递归
    private static let handledKey = "FHXHandled"

    // MARK: - Init

    public override init(
        request: URLRequest,
        cachedResponse: CachedURLResponse?,
        client: URLProtocolClient?
    ) {

        super.init(
            request: request,
            cachedResponse: cachedResponse,
            client: client
        )
    }
}

// MARK: - URLProtocol

extension FHXURLProtocol {

    public override class func canInit(
        with request: URLRequest
    ) -> Bool {

        guard let url = request.url else {
            return false
        }

        guard let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https"
        else {
            return false
        }

        if URLProtocol.property(
            forKey: Self.handledKey,
            in: request
        ) != nil {

            return false
        }

        return true
    }

    public override class func canInit(
        with task: URLSessionTask
    ) -> Bool {

        let request = task.currentRequest

        guard let request else {
            return false
        }

        return canInit(with: request)
    }

    public override class func canonicalRequest(
        for request: URLRequest
    ) -> URLRequest {

        return request
    }

    // MARK: - Start Loading
    public override func startLoading() {

        startTime = Date()
        
        requestBodyData = nil
        responseData.removeAll(keepingCapacity: true)

        // MARK: ① 获取真正的 Body

        guard let body = bodyData(from: request) else {

            startRealRequest(
                with: request,
                bodyData: nil
            )

            return
        }

        requestBodyData = body

        // MARK: ② 创建真正发送的 Request

        startRealRequest(
            with: request,
            bodyData: body
        )
    }

    // MARK: - Stop Loading

    public override func stopLoading() {

        // 如果请求已经正常完成
        // 不需要再次取消

        guard !isFinished else {
            return
        }

        realTask?.cancel()

        realTask = nil

        realSession?.invalidateAndCancel()

        realSession = nil
    }
}

// MARK: - Request Body

private extension FHXURLProtocol {

    /// 获取 Request Body
    ///
    /// 优先读取 httpBody
    ///
    /// 如果 httpBody 不存在
    /// 再读取 httpBodyStream

    func bodyData(
        from request: URLRequest
    ) -> Data? {

        // MARK: ① 直接 Body

        if let httpBody = request.httpBody {

            return httpBody
        }

        // MARK: ② Body Stream

        guard let stream = request.httpBodyStream else {
            return nil
        }

        stream.open()

        defer {
            stream.close()
        }

        let data = NSMutableData()

        let bufferSize = 16 * 1024

        let buffer = UnsafeMutablePointer<UInt8>.allocate(
            capacity: bufferSize
        )

        defer {
            buffer.deallocate()
        }

        while stream.hasBytesAvailable {

            let length = stream.read(
                buffer,
                maxLength: bufferSize
            )

            if length <= 0 {
                break
            }

            data.append(
                buffer,
                length: length
            )
        }

        guard data.length > 0 else {
            return nil
        }

        return data as Data
    }
}

// MARK: - Network Log

private extension FHXURLProtocol {

    func saveNetworkLog(
        request: URLRequest,
        requestBody: Data?,
        response: URLResponse?,
        data: Data?,
        error: Error?
    ) {

        // MARK: URL

        let url = request.url?.absoluteString ?? ""

        // MARK: Method

        let method = request.httpMethod ?? "GET"

        // MARK: Headers

        let headers = redactedHeaders(request.allHTTPHeaderFields ?? [:])

        // MARK: Parameter

        let parameter =
            requestBody.flatMap {
                String(
                    data: $0,
                    encoding: .utf8
                )
            } ?? ""

        // MARK: Response

        let responseString =
            String(
                data: data ?? Data(),
                encoding: .utf8
            ) ?? ""

        // MARK: StatusCode

        let statusCode =
            (response as? HTTPURLResponse)?
            .statusCode ?? 0

        // MARK: CostTime

        let cost =
            Date().timeIntervalSince(
                startTime ?? Date()
            )

        let costTime = Int(cost * 1000)

        // MARK: Log
        
        let log =
            """
            Method : \(method)

            URL : \(url)

            StatusCode : \(statusCode)

            CostTime : \(costTime) ms

            Error : \(error?.localizedDescription ?? "nil")

            Headers :
            \(prettyJSON(headers))

            Parameters :
            \(prettyJSONString(parameter))

            Response :
            \(prettyJSONString(responseString))
            """

        FHXLog.shared.log(log, .network)

    }
    
    // MARK: - Headers

    private func redactedHeaders(
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

private extension FHXURLProtocol {

    func startRealRequest(
        with request: URLRequest,
        bodyData: Data?
    ) {

        guard let url = request.url else {

            let error = NSError(
                domain: "FHXURLProtocol",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "URL 不存在"
                ]
            )

            client?.urlProtocol(
                self,
                didFailWithError: error
            )

            return
        }

        // MARK: - 创建新的 Request

        let forwardRequest = NSMutableURLRequest(
            url: url
        )

        // MARK: - 保留原始 Request 配置

        forwardRequest.httpMethod =
            request.httpMethod ?? "GET"

        forwardRequest.allHTTPHeaderFields =
            request.allHTTPHeaderFields

        forwardRequest.cachePolicy =
            request.cachePolicy

        forwardRequest.timeoutInterval =
            request.timeoutInterval

        forwardRequest.mainDocumentURL =
            request.mainDocumentURL

        forwardRequest.networkServiceType =
            request.networkServiceType

        forwardRequest.httpShouldHandleCookies =
            request.httpShouldHandleCookies

        forwardRequest.httpShouldUsePipelining =
            request.httpShouldUsePipelining

        // MARK: - 恢复 Body

        if let bodyData {

            if request.httpBodyStream != nil {

                // 原始请求使用 Body Stream
                // 读取完成后必须重新创建一个新的 Stream

                forwardRequest.httpBodyStream =
                    InputStream(data: bodyData)

            } else {

                // 原始请求使用普通 httpBody

                forwardRequest.httpBody =
                    bodyData
            }
        }

        // MARK: - 防止无限递归

        URLProtocol.setProperty(
            true,
            forKey: Self.handledKey,
            in: forwardRequest
        )

        // MARK: - 创建真正执行请求的 Session

        let configuration =
            URLSessionConfiguration.default

        // 内部请求不要再次进入 FHXURLProtocol

        configuration.protocolClasses = []

        let session = URLSession(
            configuration: configuration,
            delegate: self,
            delegateQueue: nil
        )

        realSession = session

        // MARK: - 创建 Task

        let task = session.dataTask(
            with: forwardRequest as URLRequest
        )

        realTask = task

        task.resume()
    }
    
}

// MARK: - URLSessionDataDelegate

extension FHXURLProtocol: URLSessionDataDelegate {

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping (
            URLSession.ResponseDisposition
        ) -> Void
    ) {

        client?.urlProtocol(
            self,
            didReceive: response,
            cacheStoragePolicy: .notAllowed
        )

        completionHandler(.allow)
    }

    public func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {

        // MARK: 转发响应数据
        //
        // 必须先把数据交还给真正的调用方，
        // 否则 URLSession.shared 收到的 body 永远是空的，
        // 这里只保存到 responseData 会导致业务拿不到数据。

        client?.urlProtocol(
            self,
            didLoad: data
        )

        // MARK: 保存数据用于日志展示

        responseData.append(data)

    }

    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {

        isFinished = true

        saveNetworkLog(
            request: request,
            requestBody: requestBodyData,
            response: task.response,
            data: responseData,
            error: error
        )

        if let error {

            client?.urlProtocol(
                self,
                didFailWithError: error
            )

        } else {

            client?.urlProtocolDidFinishLoading(
                self
            )
        }

        realTask = nil

        session.finishTasksAndInvalidate()

        realSession = nil
    }
}
