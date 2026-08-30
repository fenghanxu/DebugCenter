//
//  FHXDebugGesture.swift
//  DebugCenter
//
//  Created by imac on 2026/8/30.
//


import UIKit

public final class FHXDebugGesture {

    // MARK: - Singleton

    public static let shared = FHXDebugGesture()

    private init() {}

    // MARK: - Property

    private weak var window: UIWindow?

    private var tripleTapGesture: UITapGestureRecognizer?

}

// MARK: - Public

public extension FHXDebugGesture {

    /// 开始监听全局三击
    func start() {

        // 已经安装
        if tripleTapGesture != nil {

            return
        }

        installGesture()
    }

    /// 停止监听
    func stop() {

        guard let gesture = tripleTapGesture else {

            return
        }

        window?.removeGestureRecognizer(gesture)

        tripleTapGesture = nil

        window = nil

        print("🛑 DebugCenter Gesture Stopped")
    }
}

// MARK: - Install

private extension FHXDebugGesture {

    func installGesture() {

        guard let window = currentWindow() else {

            print("⚠️ DebugCenter: Window 获取失败")

            return
        }

        self.window = window

        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTripleTap)
        )

        gesture.numberOfTapsRequired = 3

        gesture.numberOfTouchesRequired = 1

        gesture.cancelsTouchesInView = false

        window.addGestureRecognizer(gesture)

        tripleTapGesture = gesture

        print("✅ DebugCenter Gesture Started")

        print("🪟 DebugCenter Window:", window)
    }
}

// MARK: - Action

private extension FHXDebugGesture {

    @objc
    func handleTripleTap() {

        print("🔥 DebugCenter Triple Tap")

        guard let viewController = currentViewController() else {

            print(
                "⚠️ DebugCenter: 当前 ViewController 获取失败"
            )

            return
        }

        print(
            "📱 Current ViewController:",
            String(
                describing: type(of: viewController)
            )
        )

        FHXDebugCenter.show(
            from: viewController
        )
    }
    
}

// MARK: - Window

private extension FHXDebugGesture {

    /// 获取当前 App Window
    func currentWindow() -> UIWindow? {

        let scenes =
            UIApplication.shared.connectedScenes
                .compactMap {
                    $0 as? UIWindowScene
                }

        // ① 优先寻找 KeyWindow
        for scene in scenes {

            if let window =
                scene.windows.first(
                    where: {
                        $0.isKeyWindow
                    }
                ) {

                return window
            }
        }

        // ② 找到当前正在使用的 WindowScene
        for scene in scenes {

            if scene.activationState == .foregroundActive {

                if let window =
                    scene.windows.first(
                        where: {
                            !$0.isHidden &&
                            $0.alpha > 0 &&
                            $0.windowLevel == .normal
                        }
                    ) {

                    return window
                }
            }
        }

        // ③ 最后兜底
        for scene in scenes {

            if let window =
                scene.windows.first(
                    where: {
                        !$0.isHidden &&
                        $0.alpha > 0
                    }
                ) {

                return window
            }
        }

        return nil
    }
}

// MARK: - ViewController

private extension FHXDebugGesture {

    func currentViewController() -> UIViewController? {

        guard let window = window else {

            return nil
        }

        return topViewController(
            from: window.rootViewController
        )
    }

    func topViewController(
        from viewController: UIViewController?
    ) -> UIViewController? {

        guard let viewController else {

            return nil
        }

        // UINavigationController
        if let navigationController =
            viewController as? UINavigationController {

            return topViewController(
                from: navigationController.visibleViewController
            )
        }

        // UITabBarController
        if let tabBarController =
            viewController as? UITabBarController {

            return topViewController(
                from: tabBarController.selectedViewController
            )
        }

        // Presented ViewController
        if let presentedViewController =
            viewController.presentedViewController {

            return topViewController(
                from: presentedViewController
            )
        }

        return viewController
    }
}
