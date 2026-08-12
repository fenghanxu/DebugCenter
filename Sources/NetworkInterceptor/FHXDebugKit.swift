
/// 启动入口   初始化网络拦截器
import Foundation

public final class FHXDebugKit {

    public static func start() {

        FHXNetworkInterceptor.start()
        
        print("FHXDebugKit Started")
    }
}
