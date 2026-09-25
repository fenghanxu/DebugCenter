

import UIKit

protocol FHXSearchViewDelegate: NSObjectProtocol {
    func fhxSearchView(view: FHXSearchView, searchContent text: String, returnLogType logType:LogType)
    func fhxSearchView(view: FHXSearchView, buttonClick button: UIButton)
}

enum LogType {
    case current
    case history
}

class FHXSearchView: UIView {
    
    weak var delegate: FHXSearchViewDelegate?

    var logType: LogType = .current
    
    var isShowSearchView:Bool = false {
        didSet {
            if isShowSearchView {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    guard let self = self else { return }
                    self.alpha = 1.0
                })
            } else {
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    guard let self = self else { return }
                    self.alpha = 0.0
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        build()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy private var searchView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 20.0
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: FHXSearchView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "cancel", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        
        button.tag = 2
        button.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var searchButton: UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: FHXSearchView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "search", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        
        button.layer.cornerRadius = 19
        button.clipsToBounds = true
        return button
    }()
    
    lazy private var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        return view
    }()
    
    lazy private var textfield: UITextField = {
        var textfield = UITextField()
        textfield.textColor = .black
        textfield.textAlignment = .left
        textfield.font = UIFont.systemFont(ofSize: 14)
        textfield.placeholder = "请输入搜索词"
        textfield.clearButtonMode = .always//显示本文清空按钮
        textfield.delegate = self
        return textfield
    }()

    private func build() {
        backgroundColor = .white
        
        addSubview(searchView)
        addSubview(cancelButton)
        searchView.addSubview(searchButton)
        searchView.addSubview(line)
        searchView.addSubview(textfield)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        searchView.frame   = CGRectMake(0, 2, 265, 40)
        searchButton.frame = CGRectMake(0, 1, 38, 38)
        line.frame         = CGRectMake(38 , 10, 1, 20)
        textfield.frame    = CGRectMake(45, 5, 265 - 49, 30)
        cancelButton.frame = CGRectMake(CGRectGetMaxX(searchView.frame) + 10, 5.5, 33, 33)
    }
    
    @objc private func cancelButtonClick() {
        isShowSearchView = false
        textfield.text = String()
        delegate?.fhxSearchView(view: self, buttonClick: cancelButton)
    }

}

extension FHXSearchView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) {
            delegate?.fhxSearchView(view: self, searchContent: newText, returnLogType: logType)
        }
        return true
    }
}


