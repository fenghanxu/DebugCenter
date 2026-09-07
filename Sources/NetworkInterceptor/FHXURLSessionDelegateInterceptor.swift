//
//  FHXURLSessionDelegateInterceptor.swift
//  DebugCenter
//
//  Created by fenghanxu on 2026/9/7.
//

import Foundation
import ObjectiveC.runtime

final class FHXURLSessionDelegateInterceptor {

    private static var didStart = false

    // MARK: - Start

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true

        guard let delegateClass = NSClassFromString(
            "Alamofire.SessionDelegate"
        ) else {

            print(
                "⚠️ FHX: 未找到 Alamofire.SessionDelegate，跳过 Alamofire Hook"
            )

            return
        }

        print(
            "✅ FHX: 找到 Alamofire.SessionDelegate"
        )

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

        print(
            "✅ FHX: Alamofire SessionDelegate Hook 完成"
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

            print(
                """
                ❌ FHX: Delegate Hook 失败
                selector: \(NSStringFromSelector(originalSelector))
                """
            )

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
         如果 Alamofire.SessionDelegate 自己没有实现 swizzledSelector，
         就把原方法和 Hook 方法都放到 Alamofire.SessionDelegate 自己的
         method list 中。

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

        objc_setAssociatedObject(
            dataTask,
            &FHXResponseDataKey,
            Data(),
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        print(
            """
            🔵 FHX Alamofire Response:

            \(response)
            """
        )

        // 调用 Alamofire 原来的实现
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
            ) as? Data ?? Data()

        responseData.append(data)

        objc_setAssociatedObject(
            dataTask,
            &FHXResponseDataKey,
            responseData,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        // 调用 Alamofire 原来的实现
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
         如果这个 Task 是我们前面
         dataTask(with:completionHandler:)
         Hook 创建的，

         那么它已经会在 completionHandler 中记录一次。

         这里跳过，防止重复日志。
         */
        if objc_getAssociatedObject(
            task,
            &FHXCompletionHandlerKey
        ) as? Bool == true {

            fhx_urlSession(
                session,
                task: task,
                didCompleteWithError: error
            )

            return
        }

        // Alamofire DataRequest
        if task is URLSessionDataTask {

            FHXNetworkLogger.log(
                task: task,
                error: error
            )
        }

        // 调用 Alamofire 原来的实现
        fhx_urlSession(
            session,
            task: task,
            didCompleteWithError: error
        )
    }
}
