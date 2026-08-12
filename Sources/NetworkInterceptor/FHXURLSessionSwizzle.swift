
import Foundation
import ObjectiveC.runtime

// 为什么要 Hook resume，因为是网路请求的必经之路

final class FHXURLSessionSwizzle {

    static func start() {

        let cls: AnyClass = URLSessionTask.self

        let original = class_getInstanceMethod( cls, #selector(URLSessionTask.resume))

        let swizzled = class_getInstanceMethod(cls, #selector(URLSessionTask.fhx_resume))

        guard let original, let swizzled else { return }

        method_exchangeImplementations(original, swizzled)

        print("URLSessionTask Resume Swizzle Success")
    }
}
