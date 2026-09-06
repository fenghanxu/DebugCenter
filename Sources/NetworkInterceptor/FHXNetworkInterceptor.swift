/// 整个网络监控初始化

import Foundation

final class FHXNetworkInterceptor {

    private static var didStart = false

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true
        
        // 2. Hook URLSessionTask.resume
        FHXURLSessionSwizzle.start()

        // 3. Hook URLSession.dataTask
        FHXCompletionSwizzle.start()
    }
}
