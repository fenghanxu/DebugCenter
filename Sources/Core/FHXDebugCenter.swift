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

        print("FHXDebugCenter Started")
    }

    // MARK: - Show

    static func show(from viewController: UIViewController) {

        print(
            "🚀 DebugCenter Show From:",
            String(
                describing: type(of: viewController)
            )
        )

        // 如果当前已经是日志页面，不重复打开
        if viewController is FHXLogViewController {
            return
        }

        // 创建日志页面
        let logViewController = FHXLogViewController()

        // 创建独立导航控制器
        let navigationController = UINavigationController(
            rootViewController: logViewController
        )

        // 全屏显示
        navigationController.modalPresentationStyle = .fullScreen

        // 显示 DebugCenter
        viewController.present(
            navigationController,
            animated: true
        )
    }
}
