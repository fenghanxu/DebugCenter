
import Foundation

final class FHXNetworkInterceptor {

    private static var didStart = false

    static func start() {

        guard !didStart else { return }

        // 防止重复初始化
        didStart = true
        
        // 只使用 URLProtocol 方案
        URLProtocol.registerClass(FHXURLProtocol.self)

    }
}
