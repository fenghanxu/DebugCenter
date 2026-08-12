
import Foundation
import ObjectiveC.runtime

extension URLSessionConfiguration {
    static func fhx_swizzle() {
        swizzleDefault()
        swizzleEphemeral()
    }
}

// MARK: - Swizzle
private extension URLSessionConfiguration {

    static func swizzleDefault() {

        guard
            let original = class_getClassMethod(self, #selector(getter: URLSessionConfiguration.default)),
            let swizzled = class_getClassMethod(self, #selector(getter: URLSessionConfiguration.fhx_default))
        else {
            return
        }

        method_exchangeImplementations(original, swizzled)
    }

    static func swizzleEphemeral() {

        guard
            let original = class_getClassMethod(self, #selector(getter: URLSessionConfiguration.ephemeral)),
            let swizzled = class_getClassMethod(self, #selector(getter: URLSessionConfiguration.fhx_ephemeral))
        else {
            return
        }

        method_exchangeImplementations(original, swizzled)
    }
}

// MARK: - Swizzled Getter
extension URLSessionConfiguration {

    @objc
    class var fhx_default: URLSessionConfiguration {
        let config = fhx_default
        injectProtocol(into: config)
        return config
    }

    @objc
    class var fhx_ephemeral: URLSessionConfiguration {
        let config = fhx_ephemeral
        injectProtocol(into: config)
        return config
    }
}

// MARK: - Inject
private extension URLSessionConfiguration {

    static func injectProtocol(into configuration: URLSessionConfiguration) {

        print("🔥 Inject Protocol")

        let protocolClass = FHXURLProtocol.self

        var classes = configuration.protocolClasses ?? []

        if !classes.contains(where: { $0 == protocolClass }) {
            classes.insert(protocolClass, at: 0)
            configuration.protocolClasses = classes
            print("✔️ Injected:", classes)
        } else {
            print("✔️ Already injected")
        }
    }
}
