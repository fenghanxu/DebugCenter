import Foundation

final class FHXNetworkInterceptor {

    private static var didStart = false

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true

        // Hook URLSessionTask.resume
        FHXURLSessionSwizzle.start()

        // Hook URLSession.dataTask
        FHXCompletionSwizzle.start()

        // Hook Alamofire SessionDelegate
        FHXURLSessionDelegateInterceptor.start()
    }
}
