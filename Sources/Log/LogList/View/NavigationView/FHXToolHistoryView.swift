

import UIKit

protocol FHXToolHistoryViewDelegate: NSObjectProtocol {
    func fhxToolHistoryView(view: FHXToolHistoryView, buttonClick button:UIButton)
}

class FHXToolHistoryView: UIView {

    weak var delegate: FHXToolHistoryViewDelegate?
    
    lazy private var cancelButton:UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: FHXToolHistoryView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "nav_back", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        
        button.tag = 7
        button.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var filterButton: UIButton = {
        let button = UIButton()
        button.tag = 3
        button.setTitle("筛选", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(filterButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var searchButton: UIButton = {
        let button = UIButton()
        button.tag = 4
        button.setTitle("搜索", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(searchButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var exportButton: UIButton = {
        let button = UIButton()
        button.tag = 5
        button.setTitle("导出", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(exportButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy private var clearnButton: UIButton = {
        let button = UIButton()
        button.tag = 6
        button.setTitle("清空日志", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(clearnButtonClick), for: .touchUpInside)
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
        addSubview(filterButton)
        addSubview(searchButton)
        addSubview(exportButton)
        addSubview(clearnButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cancelButton.frame = CGRectMake(0, 0, screenWidthSDK * 0.2, 44)
        filterButton.frame = CGRectMake(CGRectGetMaxX(cancelButton.frame), 0, screenWidthSDK * 0.2, 44)
        searchButton.frame = CGRectMake(CGRectGetMaxX(filterButton.frame), 0, screenWidthSDK * 0.2, 44)
        exportButton.frame = CGRectMake(CGRectGetMaxX(searchButton.frame), 0, screenWidthSDK * 0.2, 44)
        clearnButton.frame = CGRectMake(CGRectGetMaxX(exportButton.frame), 0, screenWidthSDK * 0.2, 44)

    }

}

extension FHXToolHistoryView {
    
    @objc
    private func filterButtonClick() {
        delegate?.fhxToolHistoryView(view: self, buttonClick: filterButton)
    }
    
    @objc
    private func searchButtonClick() {
        delegate?.fhxToolHistoryView(view: self, buttonClick: searchButton)
    }
    
    @objc
    private func exportButtonClick() {
        delegate?.fhxToolHistoryView(view: self, buttonClick: exportButton)
    }
    
    @objc
    private func clearnButtonClick() {
        delegate?.fhxToolHistoryView(view: self, buttonClick: clearnButton)
    }
    
    @objc
    private func cancelButtonClick() {
        delegate?.fhxToolHistoryView(view: self, buttonClick: cancelButton)
    }
    
}
