

import Foundation
import ObjectiveC.runtime

// MARK: - Associated Object Keys

var FHXStartTimeKey: UInt8 = 0
var FHXRequestKey: UInt8 = 0
var FHXRequestBodyKey: UInt8 = 0

var FHXResponseKey: UInt8 = 0
var FHXResponseDataKey: UInt8 = 0
var FHXCompletionHandlerKey: UInt8 = 0

// MARK: - URLSessionTask

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

        let currentRequest =
            self.currentRequest

        let originalRequest =
            self.originalRequest

        // 优先 currentRequest
        let request =
            currentRequest
            ?? originalRequest

        if let request {

            objc_setAssociatedObject(
                self,
                &FHXRequestKey,
                request,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )

            print(
                """
                🔥 FHX resume:
                \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")
                """
            )
        }

        // 保存 HTTP Body
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

        // 调用真正的 resume
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
