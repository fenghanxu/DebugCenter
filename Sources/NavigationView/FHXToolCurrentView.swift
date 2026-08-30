

import UIKit

protocol FHXToolCurrentViewDelegate: NSObjectProtocol {
    func fhxToolCurrentView(view:FHXToolCurrentView, buttonClick button:UIButton)
}

class FHXToolCurrentView: UIView {
    
    weak var delegate: FHXToolCurrentViewDelegate?
    
    lazy private var cancelButton:UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: FHXToolCurrentView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "nav_back", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        button.tag = 0
        button.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var logButton: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setTitle("日志", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(logButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var historyButton: UIButton = {
        let button = UIButton()
        button.tag = 8
        button.setTitle("历史日志", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(historyButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var sandboxButton: UIButton = {
        let button = UIButton()
        button.tag = 9
        button.setTitle("沙盒", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(sandboxButtonClick), for: .touchUpInside)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        backgroundColor = .white

        addSubview(cancelButton)
        addSubview(logButton)
        addSubview(historyButton)
        addSubview(sandboxButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cancelButton.frame        = CGRectMake(0, 0, 44, 44)
        
        let logButtonRight        = CGRectGetMaxX(cancelButton.frame) + 10
        logButton.frame           = CGRectMake(logButtonRight, 0, 44, 44)
        
        let historyLogButtonRight = CGRectGetMaxX(logButton.frame) + 10
        historyButton.frame       = CGRectMake(historyLogButtonRight, 0, 66, 44)
        
        let sandboxButtonRight    = CGRectGetMaxX(historyButton.frame) + 10
        sandboxButton.frame       = CGRectMake(sandboxButtonRight, 0, 66, 44)
    }

}

// MARK: - button click
extension FHXToolCurrentView {
    @objc
    private func cancelButtonClick() {
        delegate?.fhxToolCurrentView(view: self, buttonClick: cancelButton)
    }
    
    @objc
    private func logButtonClick() {
        delegate?.fhxToolCurrentView(view: self, buttonClick: logButton)
    }
    
    @objc
    private func historyButtonClick() {
        delegate?.fhxToolCurrentView(view: self, buttonClick: historyButton)
    }
    
    @objc
    private func sandboxButtonClick() {
        delegate?.fhxToolCurrentView(view: self, buttonClick: sandboxButton)
    }
}
