
// 协议级别(Network Layer)拦截

/**
当前的FHXURLProtocol本使用方案是： URLProtocol + URLSession.shared + completion(相当于block回调)
 
 还有另一种方案： URLProtocol + URLSession.shared +  Delegate(流式返回数据)
 
 目前的架构：
 App请求
    ↓
 URLProtocol（拦截）
    ↓
 URLSession.shared.dataTask（真实请求）
    ↓
 completion block（拿到 response）
    ↓
 client?.urlProtocol(...)（回传系统）
    ↓
 saveNetworkLog（记录）
 
 */

import Foundation

public final class FHXURLProtocol: URLProtocol {

    private var startTime: Date?
    
    override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {

        print("init URLProtocol")

        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

}

// MARK: - URLProtocol

extension FHXURLProtocol {

    public override class func canInit(with request: URLRequest) -> Bool {

        guard let url = request.url else { return false }

        // ⚠️ 关键：避免系统内部协议抢占
        if url.scheme != "http" && url.scheme != "https" {
            return false
        }

        if URLProtocol.property(forKey: "FHXHandled", in: request) != nil {
            return false
        }

        return true
    }
    
    public override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else { return false }
        return canInit(with: request)
    }
    
    

    public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        print("canonicalRequest")
        return request
    }

    public override func startLoading() {

        print("🔥 startLoading")

        startTime = Date()

        guard let mutableRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return
        }

        URLProtocol.setProperty(true, forKey: "FHXHandled", in: mutableRequest)

        let task = URLSession.shared.dataTask(with: mutableRequest as URLRequest) { [weak self] data, response, error in

            guard let self else { return }

            if let response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }

            if let data {
                self.client?.urlProtocol(self, didLoad: data)
            }

            if let error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }

            self.saveNetworkLog(
                request: self.request,
                response: response,
                data: data,
                error: error
            )
        }

        task.resume()
    }

    public override func stopLoading() { }
    
    private func saveNetworkLog(request: URLRequest,
                                response: URLResponse?,
                                data: Data?,
                                error: Error?) {

        let url = request.url?.absoluteString ?? ""
        let method = request.httpMethod ?? "GET"
        let headers = request.allHTTPHeaderFields ?? [:]

        let responseString = String(data: data ?? Data(), encoding: .utf8) ?? ""

        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        let cost = Date().timeIntervalSince(startTime ?? Date())
        
        let log = """
        Method : \(method)
        URL : \(url)
        StatusCode : \(statusCode)
        CostTime : \(Int(cost * 1000)) ms
        Headers :
        \(prettyJSON(headers))
        
        Parameters :
        \(prettyJSONString(request.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }))
        
        Response :
        \(prettyJSONString(responseString))
        
        Error :
        \(error?.localizedDescription ?? "nil")
        """

        FHXLog.shared.log(log, .network)
        
        print("""

        =========================

        URLProtocal打印数据：

        Method \(method)

        URL \(url)

        Header \(prettyJSON(headers))

        Parameter \(prettyJSONString(request.httpBody.flatMap {
            String(data: $0, encoding: .utf8)
        }))

        Response \(prettyJSONString(responseString))

        StatusCode \(statusCode)

        CostTime \(Int(cost * 1000))ms

        =========================

        """)

    }
}
