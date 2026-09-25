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
    }
}

// MARK: - Install

private extension FHXDebugGesture {

    func installGesture() {

        guard let window = currentWindow() else { return }

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
    }
}

// MARK: - Action

private extension FHXDebugGesture {

    @objc
    func handleTripleTap() {

        guard let viewController = currentViewController() else {
            return
        }

        FHXDebugCenter.show(from: viewController)
        
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

        // presented 控制器位于当前控制器之上，必须优先处理。
        // 日志页本身是以 UINavigationController 形式 present 的，
        // 如果先处理导航控制器，会错误地返回被覆盖的下层页面。
        if let presentedViewController =
            viewController.presentedViewController {

            return topViewController(
                from: presentedViewController
            )
        }

        // UINavigationController
        if let navigationController =
            viewController as? UINavigationController {

            // FHXDetailViewController、FHXSandboxViewController 和
            // FHXSandboxPreviewController 都是从 FHXLogViewController
            // 所在的导航栈 push 出来的。此时应将日志页视为当前页面，
            // 不要把这些子页面当成外部页面再次触发 present。
            if let logViewController = navigationController.viewControllers
                .first(where: { $0 is FHXLogViewController }) {

                return logViewController
            }

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

        return viewController
    }
}
