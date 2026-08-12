
import UIKit

class FHXExportView: UIView {
    
    static func showCurrentView(
        array: [String],
        VCView: UIView,
        valueBlock:((NSInteger)->())?
    ) {
        let selfView = FHXExportView(with: array)
        selfView.valueBlock = valueBlock
        VCView.addSubview(selfView)
        selfView.showView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data

    private var valueBlock:((_ index: NSInteger)->())?

    private var list = [String]()

    
    init(with array: [String]) {

        list = array

        let targetRect = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )

        super.init(frame: targetRect)

        buildUI()
    }

    // MARK: - UI

    lazy private var bottomButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        return btn
    }()

    lazy private var shadowView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = .zero
        return view
    }()

    lazy private var bgView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 0.5
        view.layer.borderColor =
        UIColor(red: 210.0/255.0, green: 214.0/255.0, blue: 218.0/255.0, alpha: 1.0).cgColor
        return view
    }()

    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择导出格式"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()

    lazy private var txtButton: UIButton = {

        let button = UIButton()
        button.tag = 0
        button.setTitle("TXT", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font =
        UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy private var jsonButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setTitle("JSON", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font =
        UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        button.tag = 2
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.titleLabel?.font =
        UIFont.systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(itemClick(_:)), for: .touchUpInside)
        return button
    }()

    lazy private var line1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        return view
    }()

    lazy private var line2: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        return view
    }()

    lazy private var line3: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        return view
    }()

    func buildUI() {
        backgroundColor = .clear
        addSubview(bottomButton)
        bottomButton.addSubview(shadowView)
        shadowView.addSubview(bgView)
        bgView.contentView.addSubview(titleLabel)
        bgView.contentView.addSubview(txtButton)
        bgView.contentView.addSubview(jsonButton)
        bgView.contentView.addSubview(cancelButton)
        bgView.contentView.addSubview(line1)
        bgView.contentView.addSubview(line2)
        bgView.contentView.addSubview(line3)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width: CGFloat  = 280
        let height: CGFloat = 213
        bottomButton.frame  = bounds
        shadowView.frame    = CGRect(x: (bounds.width - width) * 0.5, y: (bounds.height - height) * 0.5, width: width, height: height)
        bgView.frame        = shadowView.bounds
        titleLabel.frame    = CGRect(x: 0, y: 0, width: width, height: 60)
        line1.frame         = CGRect(x: 0, y: 60, width: width, height: 1)
        txtButton.frame     = CGRect(x: 0, y: 61, width: width, height: 50)
        line2.frame         = CGRect(x: 0, y: 111, width: width, height: 1)
        jsonButton.frame    = CGRect(x: 0, y: 112, width: width, height: 50)
        line3.frame         = CGRect(x: 0, y: 162, width: width, height: 1)
        cancelButton.frame  = CGRect(x: 0, y: 163, width: width, height: 50)
    }

    // MARK: - Show

    func showView() {
        shadowView.alpha = 0
        shadowView.transform =
        CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.6,
            options: [.curveEaseOut]
        ) {
            self.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            self.shadowView.alpha = 1
            self.shadowView.transform = .identity
        }
    }

    func dismissView() {
        UIView.animate(
            withDuration: 0.18,
            animations: {
                self.backgroundColor = .clear
                self.shadowView.alpha = 0
                self.shadowView.transform =
                CGAffineTransform(scaleX: 0.95, y: 0.95)
            },
            completion: { _ in
                self.removeFromSuperview()
            }
        )
    }

    // MARK: - Action

    @objc private func buttonClick() {
        dismissView()
    }

    @objc private func itemClick(
        _ sender: UIButton
    ) {
        dismissView()
        valueBlock?(sender.tag)
    }
}
