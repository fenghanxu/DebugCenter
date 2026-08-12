
/// 整个网络监控初始化

import Foundation

final class FHXNetworkInterceptor {

    private static var didStart = false

    static func start() {

        guard !didStart else { return }

        // 防止重复初始化
        didStart = true
        
        // ★ 一定要先交换 Configuration
        URLSessionConfiguration.fhx_swizzle()
        
        // ⚠️ 强制预热 default / ephemeral
        _ = URLSessionConfiguration.default
        _ = URLSessionConfiguration.ephemeral

        /// Hook resume ： 拦截请求开始
        FHXURLSessionSwizzle.start()
        /// 拦截"请求结束"
        FHXCompletionSwizzle.start()

        print("FHXNetworkInterceptor Started")
    }
}
