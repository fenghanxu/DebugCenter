
/**
 这个方法整体在干什么？
 
 记录时间 + 打印请求信息 + 再放行请求
 
 打印：请求方式 + URL
 */


import Foundation
import ObjectiveC.runtime

private var FHXStartTimeKey: UInt8 = 0
private var FHXRequestKey: UInt8 = 0
private var FHXRequestBodyKey: UInt8 = 0

extension URLSessionTask {

    @objc
    func fhx_resume() {

        let startTime = Date()

        objc_setAssociatedObject(
            self,
            &FHXStartTimeKey,
            startTime,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let originalRequest = self.originalRequest
        let currentRequest = self.currentRequest

        // 优先 currentRequest，其次 originalRequest
        let request = currentRequest ?? originalRequest

        if let request {

            objc_setAssociatedObject(
                self,
                &FHXRequestKey,
                request,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        let bodyData =
            currentRequest?.httpBody
            ?? originalRequest?.httpBody

        if let bodyData {

            objc_setAssociatedObject(
                self,
                &FHXRequestBodyKey,
                bodyData,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        fhx_resume()
    }

    // MARK: - Start Time

    var fhx_startTime: Date? {

        objc_getAssociatedObject(
            self,
            &FHXStartTimeKey
        ) as? Date
    }

    // MARK: - Request

    var fhx_request: URLRequest? {

        objc_getAssociatedObject(
            self,
            &FHXRequestKey
        ) as? URLRequest
    }

    // MARK: - Request Body

    var fhx_requestBodyData: Data? {

        objc_getAssociatedObject(
            self,
            &FHXRequestBodyKey
        ) as? Data
    }
}
