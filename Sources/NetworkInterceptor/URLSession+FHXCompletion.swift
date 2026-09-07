

import Foundation
import ObjectiveC.runtime

final class FHXCompletionSwizzle {

    private static var didStart = false

    static func start() {

        guard !didStart else {
            return
        }

        didStart = true

        // Hook:
        // dataTask(with:completionHandler:)
        swizzleDataTaskWithCompletionHandler()

        // Hook:
        // dataTask(with:)
        swizzleDataTask()
    }

    // MARK: - dataTask(with:completionHandler:)

    private static func swizzleDataTaskWithCompletionHandler() {

        let cls: AnyClass = URLSession.self

        let originalSelector =
            NSSelectorFromString(
                "dataTaskWithRequest:completionHandler:"
            )

        let swizzledSelector =
            #selector(
                URLSession.fhx_dataTask(
                    with:completionHandler:
                )
            )

        guard
            let original = class_getInstanceMethod(
                cls,
                originalSelector
            ),
            let swizzled = class_getInstanceMethod(
                cls,
                swizzledSelector
            )
        else {
            return
        }

        method_exchangeImplementations(
            original,
            swizzled
        )

    }

    // MARK: - dataTask(with:)

    private static func swizzleDataTask() {

        let cls: AnyClass = URLSession.self

        let originalSelector =
            NSSelectorFromString(
                "dataTaskWithRequest:"
            )

        let swizzledSelector =
            #selector(
                URLSession.fhx_dataTask(
                    with:
                )
            )

        guard
            let original = class_getInstanceMethod(
                cls,
                originalSelector
            ),
            let swizzled = class_getInstanceMethod(
                cls,
                swizzledSelector
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


