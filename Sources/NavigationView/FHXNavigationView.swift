

import UIKit

protocol FHXNavigationViewDelegate:NSObjectProtocol {
    func fhxNavigationView(view:FHXNavigationView, buttonClick button:UIButton)
    func fhxNavigationView(view:FHXNavigationView, searchContent text:String, returnLogType logType:LogType)
}

class FHXNavigationView: UIView {
    
    weak var delegate:FHXNavigationViewDelegate?
    
    lazy private var toolCurrentView: FHXToolCurrentView = {
        let view = FHXToolCurrentView()
        view.delegate = self
        return view
    }()
    
    lazy private var toolHistoryView: FHXToolHistoryView = {
        let view = FHXToolHistoryView()
        view.delegate = self
        return view
    }()
    
    lazy private var searchCurrentView: FHXSearchView = {
        let view = FHXSearchView()
        view.alpha = 0.0
        view.delegate = self
        view.logType = .current
        return view
    }()
    
    lazy private var searchHistoryView: FHXSearchView = {
        let view = FHXSearchView()
        view.alpha = 0.0
        view.delegate = self
        view.logType = .history
        return view
    }()
    
    var isShowSearchCurrentView:Bool = false {
        didSet {
            self.searchCurrentView.isShowSearchView = isShowSearchCurrentView
        }
    }
    
    var isShowSearchHistoryView:Bool = false {
        didSet {
            self.searchHistoryView.isShowSearchView = isShowSearchHistoryView
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        
        backgroundColor = .white
        
        addSubview(toolCurrentView)
        addSubview(toolHistoryView)
        toolCurrentView.addSubview(searchCurrentView)
        toolHistoryView.addSubview(searchHistoryView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        guard let screenWidth   = screenWidth else { return }
        toolCurrentView.frame   = CGRectMake(0, 0, screenWidthSDK, 44)
        toolHistoryView.frame   = CGRectMake(screenWidthSDK, 0, screenWidthSDK, 44)
        searchCurrentView.frame = CGRectMake(5 + 44 + 10, 0, screenWidthSDK - 5 - 44 - 10, 44)
        searchHistoryView.frame = CGRectMake(5 + 44 + 10, 0, screenWidthSDK - 5 - 44 - 10, 44)
    }

}

// MARK: - button click
extension FHXNavigationView: FHXToolCurrentViewDelegate {
    func fhxToolCurrentView(view:FHXToolCurrentView, buttonClick button:UIButton) {
        delegate?.fhxNavigationView(view: self, buttonClick: button)
    }
}

extension FHXNavigationView: FHXToolHistoryViewDelegate {
    func fhxToolHistoryView(view: FHXToolHistoryView, buttonClick button: UIButton) {
        delegate?.fhxNavigationView(view: self, buttonClick: button)
    }
}

extension FHXNavigationView: FHXSearchViewDelegate {
    func fhxSearchView(view: FHXSearchView, searchContent text: String, returnLogType logType:LogType) {
        delegate?.fhxNavigationView(view: self, searchContent: text, returnLogType: logType)
    }
    
    func fhxSearchView(view: FHXSearchView, buttonClick button: UIButton) {
        delegate?.fhxNavigationView(view: self, buttonClick: button)
    }    
}
