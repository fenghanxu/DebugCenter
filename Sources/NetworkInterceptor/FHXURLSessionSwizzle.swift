
import Foundation
import ObjectiveC.runtime

final class FHXURLSessionSwizzle {

    private static var didStart = false

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true

        let cls: AnyClass = URLSessionTask.self

        guard
            let original = class_getInstanceMethod(
                cls,
                #selector(URLSessionTask.resume)
            ),
            let swizzled = class_getInstanceMethod(
                cls,
                #selector(URLSessionTask.fhx_resume)
            )
        else {
            return
        }

        method_exchangeImplementations(
            original,
            swizzled
        )
    }
}
