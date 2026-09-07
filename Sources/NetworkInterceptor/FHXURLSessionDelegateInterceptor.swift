import Foundation
import ObjectiveC.runtime

final class FHXURLSessionDelegateInterceptor {

    private static var didStart = false

    /// DebugCenter 网络日志后台处理队列
    static let logQueue = DispatchQueue(
        label: "com.fenghanxu.DebugCenter.NetworkLog",
        qos: .utility
    )

    // MARK: - Start

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true

        guard let delegateClass = NSClassFromString(
            "Alamofire.SessionDelegate"
        ) else {
            return
        }

        // Response
        swizzle(
            delegateClass: delegateClass,
            originalSelector: NSSelectorFromString(
                "URLSession:dataTask:didReceiveResponse:completionHandler:"
            ),
            swizzledSelector: #selector(
                NSObject.fhx_urlSession(
                    _:dataTask:didReceive:completionHandler:
                )
            )
        )

        // Data
        swizzle(
            delegateClass: delegateClass,
            originalSelector: NSSelectorFromString(
                "URLSession:dataTask:didReceiveData:"
            ),
            swizzledSelector: #selector(
                NSObject.fhx_urlSession(
                    _:dataTask:didReceive:
                )
            )
        )

        // Complete
        swizzle(
            delegateClass: delegateClass,
            originalSelector: NSSelectorFromString(
                "URLSession:task:didCompleteWithError:"
            ),
            swizzledSelector: #selector(
                NSObject.fhx_urlSession(
                    _:task:didCompleteWithError:
                )
            )
        )
    }

    // MARK: - Swizzle

    private static func swizzle(
        delegateClass: AnyClass,
        originalSelector: Selector,
        swizzledSelector: Selector
    ) {

        guard
            let originalMethod = class_getInstanceMethod(
                delegateClass,
                originalSelector
            ),
            let swizzledMethod = class_getInstanceMethod(
                NSObject.self,
                swizzledSelector
            )
        else {
            return
        }

        let originalIMP =
            method_getImplementation(
                originalMethod
            )

        let swizzledIMP =
            method_getImplementation(
                swizzledMethod
            )

        let originalTypes =
            method_getTypeEncoding(
                originalMethod
            )

        let swizzledTypes =
            method_getTypeEncoding(
                swizzledMethod
            )

        /*
         如果 Alamofire.SessionDelegate 自己没有实现
         swizzledSelector，就把原方法和 Hook 方法都放到
         Alamofire.SessionDelegate 自己的 method list 中。

         这样不会意外修改 NSObject 全局行为。
         */

        if class_addMethod(
            delegateClass,
            originalSelector,
            swizzledIMP,
            swizzledTypes
        ) {

            class_replaceMethod(
                delegateClass,
                swizzledSelector,
                originalIMP,
                originalTypes
            )

        } else {

            method_exchangeImplementations(
                originalMethod,
                swizzledMethod
            )
        }
    }
}

extension NSObject {

    // MARK: - didReceive Response

    @objc
    func fhx_urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse,
        completionHandler: @escaping @Sendable (
            URLSession.ResponseDisposition
        ) -> Void
    ) {

        objc_setAssociatedObject(
            dataTask,
            &FHXResponseKey,
            response,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let responseData =
            NSMutableData()

        objc_setAssociatedObject(
            dataTask,
            &FHXResponseDataKey,
            responseData,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        // 立即调用 Alamofire 原来的实现
        fhx_urlSession(
            session,
            dataTask: dataTask,
            didReceive: response,
            completionHandler: completionHandler
        )
    }

    // MARK: - didReceive Data

    @objc
    func fhx_urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {

        var responseData =
            objc_getAssociatedObject(
                dataTask,
                &FHXResponseDataKey
            ) as? NSMutableData

        if responseData == nil {

            responseData =
                NSMutableData()

            objc_setAssociatedObject(
                dataTask,
                &FHXResponseDataKey,
                responseData,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        responseData?.append(data)

        /*
         这里非常重要：

         只负责收集 Response Data，
         不执行：

         - JSON 解析
         - String 转换
         - prettyJSON
         - print
         - FHXLog.shared.log
         - 磁盘写入

         然后立即调用 Alamofire 原来的实现。
         */

        fhx_urlSession(
            session,
            dataTask: dataTask,
            didReceive: data
        )
    }

    // MARK: - Complete

    @objc
    func fhx_urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {

        /*
         如果这个 Task 是通过
         dataTask(with:completionHandler:)
         Hook 创建的，

         那么它会在 completionHandler 中记录一次。

         这里不再重复记录。
         */

        if objc_getAssociatedObject(
            task,
            &FHXCompletionHandlerKey
        ) as? Bool == true {

            // 立即调用 Alamofire 原来的实现
            fhx_urlSession(
                session,
                task: task,
                didCompleteWithError: error
            )

            return
        }

        /*
         Alamofire DataRequest：

         不要在这里同步执行 FHXNetworkLogger.log()。

         否则：

         网络请求完成
             ↓
         DebugCenter 格式化 JSON
             ↓
         FHXLog.shared.log()
             ↓
         Alamofire 原方法
             ↓
         App 收到结果

         会导致 App 网络回调变慢。

         改成：

         网络请求完成
             ↓
         后台处理 DebugCenter 日志
             ↓
         立即执行 Alamofire 原方法
             ↓
         App 收到结果
         */

        if task is URLSessionDataTask {

            let logTask = task
            let logError = error

            FHXURLSessionDelegateInterceptor.logQueue.async {

                FHXNetworkLogger.log(
                    task: logTask,
                    error: logError
                )
            }
        }

        // 立即调用 Alamofire 原来的实现
        fhx_urlSession(
            session,
            task: task,
            didCompleteWithError: error
        )
    }
}
