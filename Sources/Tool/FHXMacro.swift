//
//  FHXMacro.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/29.
//

import UIKit

// MARK: - Window

/// 当前KeyWindow
public var keyWindowAppSDK: UIWindow? {
    return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow }
}

// MARK: - StatusBar

/// 状态栏高度
public var statusBarHeightSDK: CGFloat {
    return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first?.statusBarManager?.statusBarFrame.height ?? 44
}

// MARK: - SafeArea

/// 安全区域顶部
public var safeAreaTopSDK: CGFloat {
    return keyWindowAppSDK?.safeAreaInsets.top ?? statusBarHeightSDK
}

/// 安全区域底部
public var safeAreaBottomSDK: CGFloat {
    return keyWindowAppSDK?.safeAreaInsets.bottom ?? 0
}

/// 安全区域Insets
public var safeAreaInsetsAppSDK: UIEdgeInsets {
    return keyWindowAppSDK?.safeAreaInsets ?? .zero
}

/// 是否刘海屏
public var hasNotchSDK: Bool {
    return safeAreaBottomSDK > 0
}

// MARK: - Screen
/// 屏幕宽度
public var screenWidthSDK: CGFloat {
    return UIScreen.main.bounds.width
}

/// 屏幕高度
public var screenHeightSDK: CGFloat {
    return UIScreen.main.bounds.height
}

/// 安全区域内高度
public var safeScreenHeightSDK: CGFloat {
    return screenHeightSDK - safeAreaTopSDK - safeAreaBottomSDK
}

// MARK: - Navigation

/// 导航栏高度
public func navBarHeightSDK(_ vc: UIViewController?) -> CGFloat {
    return vc?.navigationController?.navigationBar.frame.height ?? 44
}

/// 顶部总高度
public func totalTopHeightSDK(_ vc: UIViewController?) -> CGFloat {
    return statusBarHeightSDK + navBarHeightSDK(vc)
}

// MARK: - TabBar

/// TabBar总高度
public func totalBottomHeightSDK(_ vc: UIViewController?) -> CGFloat {
    if let tab = vc?.tabBarController?.tabBar, !tab.isHidden {
        return tab.frame.height
    }
    return 49
}


