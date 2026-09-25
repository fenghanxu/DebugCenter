//
//  SandboxNavigationView.swift
//  Alamofire
//
//  Created by imac on 2026/9/21.
//

import UIKit

protocol SandboxNavigationViewDelegate: NSObjectProtocol {
    func sandboxNavigationView(view: SandboxNavigationView, returnButton button: UIButton)
}

class SandboxNavigationView: UIView {
    
    weak var delegate: SandboxNavigationViewDelegate?
    
    var title: String = String() {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy private var bgView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "沙盒"
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: SandboxNavigationView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "nav_back@3x", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
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
        
        addSubview(bgView)
        bgView.frame = CGRect(x: 0, y: safeAreaTopSDK, width: screenWidthSDK, height: 44)
        
        addSubview(cancelButton)
        cancelButton.frame = CGRectMake(5, safeAreaTopSDK, 50, 50)
        
        bgView.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
        titleLabel.center = CGPoint(x: bgView.bounds.width / 2, y: bgView.bounds.height / 2 )
    }
    
    @objc
    private func cancelButtonClick() {
        delegate?.sandboxNavigationView(view: self, returnButton: cancelButton)
    }

}

