//
//  FHXDebugCenter.swift
//  DebugCenter
//
//  Created by imac on 2026/8/30.
//


import UIKit

public final class FHXDebugCenter {

    // MARK: - Start

    public static func start() {

        // 启动网络日志拦截
        FHXNetworkInterceptor.start()

        // 启动全局三击手势
        FHXDebugGesture.shared.start()
    }

    // MARK: - Show

    static func show(from viewController: UIViewController) {

        // 日志页面可能被 UINavigationController 包裹，也可能仍处于
        // present 动画中。递归检查整个当前展示链，避免连续三击重复弹出。
        if containsLogViewController(in: viewController) ||
            isInsideLogNavigationStack(viewController) {
            return
        }

        // 创建日志页面
        let logViewController = FHXLogViewController()

        // 创建独立导航控制器
        let navigationController = UINavigationController(
            rootViewController: logViewController
        )

        // 保持 present 方式，同时保留下层控制器在层级中可见。
        // 这样 FHXLogViewController 左边缘右滑时，会露出上一个控制器，
        // 而不是露出窗口的黑色背景。
        navigationController.modalPresentationStyle = .overFullScreen
        navigationController.view.backgroundColor = .white

        // 显示 DebugCenter
        viewController.present(
            navigationController,
            animated: true
        )
    }

    /// 检查当前控制器及其展示层级中是否已经存在日志页面。
    private static func containsLogViewController(
        in viewController: UIViewController?
    ) -> Bool {

        guard let viewController else {
            return false
        }

        if viewController is FHXLogViewController {
            return true
        }

        if let navigationController =
            viewController as? UINavigationController,
            navigationController.viewControllers.contains(where: {
                containsLogViewController(in: $0)
            }) {
            return true
        }

        if let tabBarController = viewController as? UITabBarController,
           tabBarController.viewControllers?.contains(where: {
               containsLogViewController(in: $0)
           }) == true {
            return true
        }

        if viewController.children.contains(where: {
            containsLogViewController(in: $0)
        }) {
            return true
        }

        return containsLogViewController(
            in: viewController.presentedViewController
        )
    }

    /// 当前控制器可能是日志页导航栈中 push 出来的子页面，例如详情页或
    /// 沙盒页面。检查父级导航栈，避免从这些页面再次弹出日志页。
    private static func isInsideLogNavigationStack(
        _ viewController: UIViewController
    ) -> Bool {

        var current: UIViewController? = viewController

        while let controller = current {
            if controller is FHXLogViewController {
                return true
            }

            if let navigationController = controller as? UINavigationController,
               navigationController.viewControllers.contains(where: {
                   $0 is FHXLogViewController
               }) {
                return true
            }

            current = controller.parent
        }

        return false
    }
}
