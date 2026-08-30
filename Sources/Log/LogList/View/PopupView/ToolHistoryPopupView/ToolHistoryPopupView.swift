
import UIKit

class ToolHistoryPopupView: UIView {

    // MARK: - Show

    static func showCurrentView(
        vc: UIViewController,
        totalTopHeight: CGFloat,
        menuList: [String],
        valueBlock: ((String) -> ())?
    ) {

        let selfView = ToolHistoryPopupView(
            vc: vc,
            totalTopHeight: totalTopHeight,
            menuList: menuList
        )

        selfView.valueBlock = valueBlock

        vc.view.addSubview(selfView)

        selfView.showMenuView()
    }

    // MARK: - Init

    init(
        vc: UIViewController,
        totalTopHeight: CGFloat,
        menuList: [String]
    ) {

        super.init(frame: UIScreen.main.bounds)

        self.vc = vc
        self.totalTopHeight = totalTopHeight
        self.menuList = menuList

        buildUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Property

    private var valueBlock: ((_ value: String) -> ())?
    private var totalTopHeight: CGFloat = 0
    private var menuList: [String] = []
    private var vc:UIViewController?

    // MARK: - UI

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

    lazy private var menuEffectView: UIVisualEffectView = {

        let blurEffect = UIBlurEffect(
            style: .systemUltraThinMaterial
        )

        let view = UIVisualEffectView(
            effect: blurEffect
        )

        view.clipsToBounds = true

        view.layer.cornerRadius = 12

        view.layer.borderWidth = 0.5

        view.layer.borderColor = UIColor(
            red: 210.0 / 255.0,
            green: 214.0 / 255.0,
            blue: 218.0 / 255.0,
            alpha: 1.0
        ).cgColor

        return view

    }()

    lazy private var menuView: FHXToolSubMenuView = {

        let view = FHXToolSubMenuView()

        view.list = menuList

        view.delegate = self

        return view

    }()

    // MARK: - Build UI

    private func buildUI() {

        backgroundColor = .clear

        addSubview(bottomButton)

        bottomButton.addSubview(shadowMenuView)

        shadowMenuView.addSubview(menuEffectView)

        menuEffectView.contentView.addSubview(menuView)
    }

    // MARK: - Layout

    override func layoutSubviews() {

        super.layoutSubviews()
        
        guard let vc = vc else { return }

        bottomButton.frame = bounds

        shadowMenuView.frame = CGRect(
            x: 40,
            y: totalTopHeightSDK(vc),
            width: 150,
            height: CGFloat(menuList.count * 44)
        )

        menuEffectView.frame = shadowMenuView.bounds

        menuView.frame = shadowMenuView.bounds
    }

    // MARK: - Show

    private func showMenuView() {

        shadowMenuView.alpha = 0

        shadowMenuView.transform = CGAffineTransform(
            translationX: 0,
            y: -10
        ).scaledBy(
            x: 0.95,
            y: 0.95
        )

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

    // MARK: - Hide

    private func hideMenuView() {

        UIView.animate(
            withDuration: 0.18,
            delay: 0,
            options: [.curveEaseIn]
        ) {

            self.backgroundColor = .clear

            self.shadowMenuView.alpha = 0

            self.shadowMenuView.transform = CGAffineTransform(
                translationX: 0,
                y: -8
            ).scaledBy(
                x: 0.98,
                y: 0.98
            )

        } completion: { _ in

            self.removeFromSuperview()
        }
    }

    // MARK: - Action

    @objc private func buttonClick() {
        hideMenuView()
    }
}

// MARK: - FHXToolSubMenuViewDelegate

extension ToolHistoryPopupView: FHXToolSubMenuViewDelegate {
    func fhxToolSubMenuView( view: FHXToolSubMenuView, didSelectRowAt indexPath: IndexPath) {
        hideMenuView()
        valueBlock?(menuList[indexPath.item])
    }
}

