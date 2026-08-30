
import UIKit

class ToolCurrentPopupView: UIView {
        
    // MARK: - Show
    static func showCurrentView(
        vc: UIViewController,
        menuList: [String],
        subMenuList: [String],
        valueBlock:((String)->())?
    ) {
        let selfView = ToolCurrentPopupView(
            vc: vc,
            menuList: menuList,
            subMenuList: subMenuList
        )
        selfView.valueBlock = valueBlock
        vc.view.addSubview(selfView)
        selfView.showMenuView()
    }
    
    init(
         vc: UIViewController,
         menuList: [String],
         subMenuList: [String]
    ) {
        
        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        
        super.init(frame: targetRect)
        
        self.vc = vc
        self.menuList       = menuList
        self.subMenuList    = subMenuList
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var valueBlock:((_ value: String)->())?
    
    private var vc:UIViewController?
    
    private var clickButton: UIButton?
    
    private var isShowSubMenu = false
    
    private var menuList:[String] = [String]()
    
    private var subMenuList:[String] = [String]()
        
    lazy private var bottomButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return btn
    }()
    
    lazy private var shadowMenuView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = .zero
        return view
    }()
    
    
    lazy private var bgMenuView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 210.0/255.0, green: 214.0/255.0, blue: 218.0/255.0, alpha: 1.0).cgColor
        return view
    }()
    
    lazy private var menuView: FHXToolMenuView = {
        let view = FHXToolMenuView()
        view.delegate = self
        view.list = menuList
        return view
    }()
    
    lazy private var shadowSubMenuView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = .zero
        view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        return view
    }()
        
    lazy private var bgSubMenuView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor(red: 210.0/255.0, green: 214.0/255.0, blue: 218.0/255.0, alpha: 1.0).cgColor
        return view
    }()
    
    lazy private var subMenuView: FHXToolSubMenuView = {
        let view = FHXToolSubMenuView()
        view.list = subMenuList
        view.delegate = self
        return view
    }()
    
    // MARK: - UI
    
    func buildUI() {
        
        backgroundColor = .clear
        
        addSubview(bottomButton)
        
        bottomButton.addSubview(shadowMenuView)
        shadowMenuView.addSubview(bgMenuView)
        bgMenuView.contentView.addSubview(menuView)
        
        bottomButton.addSubview(shadowSubMenuView)
        shadowSubMenuView.addSubview(bgSubMenuView)
        bgSubMenuView.contentView.addSubview(subMenuView)
        
        shadowSubMenuView.alpha = 0
        shadowSubMenuView.isHidden = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let vc = vc else { return }
        
        bottomButton.frame     = bounds
        shadowMenuView.frame   = CGRectMake(20, totalTopHeightSDK(vc), 150, CGFloat(44 * menuView.list.count))
        bgMenuView.frame       = shadowMenuView.bounds
        menuView.frame         = shadowMenuView.bounds
        
        shadowSubMenuView.frame   = CGRectMake(CGRectGetMaxX(shadowMenuView.frame) + 2, CGRectGetMinY(shadowMenuView.frame), 150, CGFloat(44 * subMenuView.list.count))
        bgSubMenuView.frame       = shadowSubMenuView.bounds
        subMenuView.frame         = shadowSubMenuView.bounds
    }
    
    // MARK: - Show
    
    func showMenuView() {

        shadowMenuView.alpha = 0
        shadowMenuView.transform = CGAffineTransform(
            translationX: 0,
            y: -10
        ).scaledBy(x: 0.95, y: 0.95)

        backgroundColor = UIColor.black.withAlphaComponent(0)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut]
        ) {

            self.backgroundColor = UIColor.black.withAlphaComponent(0.05)

            self.shadowMenuView.alpha = 1
            self.shadowMenuView.transform = .identity
        }
    }
    
    private func showSubMenu() {

        guard !isShowSubMenu else { return }

        isShowSubMenu = true

        shadowSubMenuView.layer.removeAllAnimations()

        shadowSubMenuView.isHidden = false
        shadowSubMenuView.alpha = 0
        shadowSubMenuView.transform = CGAffineTransform(
            scaleX: 0.92,
            y: 0.92
        )

        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.8,
            options: [.curveEaseOut]
        ) {

            self.shadowSubMenuView.alpha = 1
            self.shadowSubMenuView.transform = .identity
        }
    }
    
    // MARK: - Dismiss
    
    func hideMenuView() {

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseIn]
        ) {

            self.backgroundColor = .clear

            self.shadowMenuView.alpha = 0
            self.shadowSubMenuView.alpha = 0

            self.shadowMenuView.transform = CGAffineTransform(
                translationX: 0,
                y: -8
            ).scaledBy(
                x: 0.98,
                y: 0.98
            )

            self.shadowSubMenuView.transform = CGAffineTransform(
                scaleX: 0.95,
                y: 0.95
            )

        } completion: { _ in
            
            self.isShowSubMenu = false
            self.shadowSubMenuView.isHidden = true
            self.shadowSubMenuView.transform = .identity

            self.removeFromSuperview()
        }
    }
    
    private func hideSubMenu() {

        guard isShowSubMenu else { return }

        isShowSubMenu = false

        shadowSubMenuView.layer.removeAllAnimations()

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseIn]
        ) {

            self.shadowSubMenuView.alpha = 0

            self.shadowSubMenuView.transform = CGAffineTransform(
                scaleX: 0.95,
                y: 0.95
            )

        } completion: { _ in

            self.shadowSubMenuView.isHidden = true
            self.shadowSubMenuView.transform = .identity
        }
    }
    
    // MARK: - Action
    
    @objc func buttonClick() {
        hideMenuView()
    }
    
    @objc func closeButtonClick() {
        hideMenuView()
    }
    
}

extension ToolCurrentPopupView : FHXToolMenuViewDelegate {
    
    func fhxToolMenuView(model:FHXToolMenuView, didSelectRowAt indexPath: IndexPath) {
        if menuList[indexPath.item] == "筛选" {
            if isShowSubMenu {
                hideSubMenu()
                valueBlock?(menuList[indexPath.item])
            } else {
                showSubMenu()
            }
        } else if menuList[indexPath.item] == "搜索" {
            hideMenuView()
            valueBlock?(menuList[indexPath.item])
        } else if menuList[indexPath.item] == "导出" {
            hideMenuView()
            valueBlock?(menuList[indexPath.item])
        } else if menuList[indexPath.item] == "清空日志" {
            hideMenuView()
            valueBlock?(menuList[indexPath.item])
        }
    }
    
}

extension ToolCurrentPopupView: FHXToolSubMenuViewDelegate {
    func fhxToolSubMenuView(view: FHXToolSubMenuView, didSelectRowAt indexPath: IndexPath) {
        hideMenuView()
        valueBlock?(subMenuList[indexPath.item])
    }
}



