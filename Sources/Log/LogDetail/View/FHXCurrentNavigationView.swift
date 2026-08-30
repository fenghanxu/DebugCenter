//
//  FHXCurrentNavigationView.swift
//  DebugCenter
//
//  Created by imac on 2026/8/15.
//

import UIKit

protocol FHXCurrentNavigationViewDelegate: NSObject {
    func fhxCurrentNavigationView(view: FHXCurrentNavigationView, buttonClick: UIButton)
}

class FHXCurrentNavigationView: UIView {
    
    weak var delegate: FHXCurrentNavigationViewDelegate?
    
    private lazy var cancelButton: UIButton = {
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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    private func buildUI() {
        addSubview(cancelButton)
        cancelButton.frame = CGRectMake(0, safeAreaTopSDK, 44, 44)
        
        addSubview(titleLabel)
        titleLabel.frame = CGRectMake(54, safeAreaTopSDK, screenWidthSDK-98, 44)
    }
    
    private func extractURL(from message: String) -> String? {

        let pattern = #"URL\s*:?\s*(https?://[^\s]+)"#

        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: []
        ) else {
            return nil
        }


        let range = NSRange(
            message.startIndex..<message.endIndex,
            in: message
        )


        guard let result = regex.firstMatch(
            in: message,
            options: [],
            range: range
        ) else {
            return nil
        }


        guard let urlRange = Range(
            result.range(at: 1),
            in: message
        ) else {
            return nil
        }


        return String(message[urlRange])
    }
    
    func setData(_ message: String) {
        titleLabel.text = extractURL(from: message)
    }
    
}

extension FHXCurrentNavigationView {
    
    @objc
    private func cancelButtonClick() {
        delegate?.fhxCurrentNavigationView(view: self, buttonClick: cancelButton)
    }
    
}
