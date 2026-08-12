

import UIKit

public class FHXLogViewController: UIViewController {
    
    lazy private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.contentSize = CGSize(width: view.bounds.size.width * 2, height: (screenHeightSDK - totalTopHeightSDK(self)))
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .red
        return scrollView
    }()
    
    lazy private var navigatonView : FHXNavigationView = {
        let navigationView = FHXNavigationView(frame: view.frame)
        navigationView.delegate = self
        navigationView.backgroundColor = .green
        return navigationView
    }()

    lazy private var currentTableView: UITableView = {
        var tableView = UITableView()
        tableView.tag = 101
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
        tableView.register(FHXLogCell.self, forCellReuseIdentifier: FHXLogCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        return tableView
    }()
    
    lazy private var historyTableView: UITableView = {
        var tableView = UITableView()
        tableView.tag = 102
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(FHXLogCell.self, forCellReuseIdentifier: FHXLogCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        return tableView
    }()
    
    /// 筛选枚举当前数据
    private enum FHXLogFilterCurrentState {
        case allCurrentFilter
        case debugCurrentFilter
        case networkCurrentFilter
        case errorCurrentFilter
        case crashCurrentFilter
    }

    /// 当前显示日志
    private var filterCurrentLogs: [FHXLogModel] = []

    /// 当前筛选状态
    private var filterCurrentState: FHXLogFilterCurrentState = .allCurrentFilter

    /// 当前关键词
    private var searchCurrentTerm = String()
    
    /// 筛选枚举历史数据
    private enum FHXLogFilterHistoryState {
        case allHistoryFilter
        case debugHistoryFilter
        case networkHistoryFilter
        case errorHistoryFilter
        case crashHistoryFilter
    }

    /// 历史显示日志
    private var filterHistoryLogs: [FHXLogModel] = []

    /// 历史筛选状态
    private var filterHistoryState: FHXLogFilterHistoryState = .allHistoryFilter

    /// 历史关键词
    private var searchHistoryTerm = String()
    
    /// 行距是8，只执行一次，目的，提高cell的构建效率
    private static let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8
        return style.copy() as! NSParagraphStyle
    }()

    /// 初始化富文本一次，目的，提高cell的构建效率
    private static let normalAttributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: paragraphStyle,
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.black
    ]
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        applyFilterCurrentData()
        applyFilterHistoryData()
        currentTableView.reloadData()
        historyTableView.reloadData()
        addNotification()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame       = CGRectMake(0, safeAreaTopSDK, screenWidthSDK, screenHeightSDK - safeAreaTopSDK)
        navigatonView.frame    = CGRectMake(0, 0, screenWidthSDK * 2, 44)
        currentTableView.frame = CGRectMake(0, CGRectGetMaxY(navigatonView.frame), screenWidthSDK, screenHeightSDK - safeAreaTopSDK - 44)
        historyTableView.frame = CGRectMake(screenWidthSDK, CGRectGetMaxY(navigatonView.frame), screenWidthSDK, screenHeightSDK - safeAreaTopSDK - 44)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(navigatonView)
        scrollView.addSubview(currentTableView)
        scrollView.addSubview(historyTableView)
    }

    private func addNotification() {

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(logDidAppendCurrentData(_:)),
            name: .logDidAppendCurrentData,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(logDidClearCurrentData),
            name: .logDidClearCurrentData,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(logDidClearHistoryData),
            name: .logDidClearHistoryData,
            object: nil
        )
    }
    
    private func scrollToBottom() {

        guard filterCurrentLogs.count > 0 else {
            return
        }

        let indexPath = IndexPath(
            row: filterCurrentLogs.count - 1,
            section: 0
        )

        currentTableView.scrollToRow(
            at: indexPath,
            at: .bottom,
            animated: true
        )
    }
    
    private func searchCurrent(_ keyword: String) {
        searchCurrentTerm = keyword
        
        applyFilterCurrentData()

        currentTableView.reloadData()
    }
    
    private func searchHistory(_ keyword: String) {

        searchHistoryTerm = keyword

        applyFilterHistoryData()

        historyTableView.reloadData()
    }
    
    /// 关键搜索词高亮
    func highlightText(
        text: String,
        keyword: String
    ) -> NSAttributedString {

        let attr = NSMutableAttributedString(
            string: text,
            attributes: Self.normalAttributes
        )

        guard !keyword.isEmpty else {
            return attr
        }

        let nsText = text as NSString

        var searchRange = NSRange(
            location: 0,
            length: nsText.length
        )

        while true {

            let range = nsText.range(
                of: keyword,
                options: .caseInsensitive,
                range: searchRange
            )

            if range.location == NSNotFound {
                break
            }

            attr.addAttributes(
                [
                    .foregroundColor: UIColor.red,
                    .font: UIFont.boldSystemFont(ofSize: 14)
                ],
                range: range
            )

            let nextLocation = range.location + range.length

            searchRange = NSRange(
                location: nextLocation,
                length: nsText.length - nextLocation
            )
        }

        return attr
    }

    // 判断是否满足筛选的方法
    private func shouldDisplayCurrent(_ model: FHXLogModel) -> Bool {

        // MARK: - 等级过滤
        let levelMatch: Bool

        switch filterCurrentState {

        case .allCurrentFilter:
            levelMatch = true

        case .debugCurrentFilter:
            levelMatch = model.level == .debug

        case .networkCurrentFilter:
            levelMatch = model.level == .network

        case .errorCurrentFilter:
            levelMatch = model.level == .error

        case .crashCurrentFilter:
            levelMatch = model.level == .crash
        }

        guard levelMatch else {
            return false
        }

        // MARK: - 搜索过滤
        guard !searchCurrentTerm.isEmpty else {
            return true
        }

        let keyword = searchCurrentTerm.lowercased()

        return
            model.message.lowercased().contains(keyword) ||
            model.file.lowercased().contains(keyword) ||
            model.function.lowercased().contains(keyword)
    }
    
    //筛选方法
    private func applyFilterCurrentData() {
        filterCurrentLogs = FHXLog.shared.currentLogs().filter {
            shouldDisplayCurrent($0)
        }
    }
    
    // 判断是否满足筛选的方法
    private func shouldDisplayHistory(_ model: FHXLogModel) -> Bool {

        // MARK: 等级过滤

        let levelMatch: Bool

        switch filterHistoryState {

        case .allHistoryFilter:
            levelMatch = true

        case .debugHistoryFilter:
            levelMatch = model.level == .debug

        case .networkHistoryFilter:
            levelMatch = model.level == .network

        case .errorHistoryFilter:
            levelMatch = model.level == .error

        case .crashHistoryFilter:
            levelMatch = model.level == .crash
        }

        guard levelMatch else {
            return false
        }

        // MARK: 搜索过滤

        guard !searchHistoryTerm.isEmpty else {
            return true
        }

        let keyword = searchHistoryTerm.lowercased()

        return
            model.message.lowercased().contains(keyword)
            ||
            model.file.lowercased().contains(keyword)
            ||
            model.function.lowercased().contains(keyword)
    }
    
    private func applyFilterHistoryData() {
        filterHistoryLogs = FHXLog.shared.historyLogs().filter {
            shouldDisplayHistory($0)
        }
    }

}

/// Notification
extension FHXLogViewController {
    
    @objc
    private func logDidAppendCurrentData(_ notification: Notification) {

        guard let model = notification.object as? FHXLogModel else {
            return
        }

        /*
         判断当前过滤是否需要显示
         如果新来的消息类型跟tableview筛选的类型一致才有必要刷新，不然没有必要刷新浪费性能
         */
        guard shouldDisplayCurrent(model) else {
            return
        }

        filterCurrentLogs.append(model)

        //  拿到最后一行
        let indexPath = IndexPath(row: filterCurrentLogs.count - 1, section: 0)
        //  刷新最后一行
        currentTableView.performBatchUpdates({
            currentTableView.insertRows(at: [indexPath], with: .none)
        }) { _ in
            //tableview移动到最后一行
            self.scrollToBottom()
        }
    }
    
    @objc
    private func logDidClearCurrentData() {
        filterCurrentLogs.removeAll()
        currentTableView.reloadData()
    }
    
    @objc
    private func logDidClearHistoryData() {
        filterHistoryLogs.removeAll()
        historyTableView.reloadData()
    }
}

extension FHXLogViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView.tag {
        case 101:
            return filterCurrentLogs[indexPath.row].cellHeight
        case 102:
            return filterHistoryLogs[indexPath.row].cellHeight
        default:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView.tag {
        case 101:
            return filterCurrentLogs.count
        case 102:
            return filterHistoryLogs.count
        default:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FHXLogCell = FHXLogCell.cell(with: tableView)
        switch tableView.tag {
        case 101:
            
            cell.levelLabel.text = "\(filterCurrentLogs[indexPath.row].level)"
            
            cell.timeLabel.text = filterCurrentLogs[indexPath.row].timeString
            
            cell.levelLabel.backgroundColor = filterCurrentLogs[indexPath.item].level.color
            
            let messageString = filterCurrentLogs[indexPath.row].methodString
            if messageString.range(of: searchCurrentTerm, options: .caseInsensitive) != nil { // 判断 关键词忽略大小写
                cell.methodNameLabel.attributedText = highlightText(text: messageString, keyword: searchCurrentTerm)
            } else {
                cell.methodNameLabel.text = filterCurrentLogs[indexPath.row].methodString
            }
            
            if searchCurrentTerm != String() && filterCurrentLogs[indexPath.row].message.range(of: searchCurrentTerm, options: .caseInsensitive) != nil {
                cell.contentLabel.attributedText = highlightText(text: filterCurrentLogs[indexPath.row].message, keyword: searchCurrentTerm)
            } else {
                cell.contentLabel.attributedText = filterCurrentLogs[indexPath.row].messageAttributed
            }
            
            if filterCurrentLogs[indexPath.row].contentFullHeight > 200 {
                cell.showExpandButton(true)
            }else{
                cell.showExpandButton(false)
                cell.expandBlock = nil
            }

            return cell
        case 102:
            cell.levelLabel.text = "\(filterHistoryLogs[indexPath.row].level)"
            
            cell.timeLabel.text = filterHistoryLogs[indexPath.row].timeString
            
            cell.levelLabel.backgroundColor = filterHistoryLogs[indexPath.row].level.color
    
            let messageString = filterHistoryLogs[indexPath.row].methodString
            if messageString.range(of: searchHistoryTerm, options: .caseInsensitive) != nil { // 判断 关键词忽略大小写
                cell.methodNameLabel.attributedText = highlightText(text: messageString, keyword: searchHistoryTerm)
            } else {
                cell.methodNameLabel.text = filterHistoryLogs[indexPath.row].methodString
            }
    
            if searchHistoryTerm != String() && filterHistoryLogs[indexPath.row].message.range(of: searchHistoryTerm, options: .caseInsensitive) != nil {
                cell.contentLabel.attributedText = highlightText(text: filterHistoryLogs[indexPath.row].message, keyword: searchHistoryTerm)
            } else {
                cell.contentLabel.attributedText = filterHistoryLogs[indexPath.row].messageAttributed
            }
            
            if filterHistoryLogs[indexPath.row].contentFullHeight > 200 {
                cell.showExpandButton(true)
            }else{
                cell.showExpandButton(false)
                cell.expandBlock = nil
            }

            return cell
        default:
            return UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView.tag {
        case 101:
            if filterCurrentLogs[indexPath.row].contentFullHeight > 200 {
                FHXDetailView.showCurrentView(model: filterCurrentLogs[indexPath.row], VCView: view)
            }
        case 102:
            if filterHistoryLogs[indexPath.row].contentFullHeight > 200 {
                FHXDetailView.showCurrentView(model: filterHistoryLogs[indexPath.row], VCView: view)
            }
        default:
            break
        }
    }

    public func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        var model: FHXLogModel?
        
        switch tableView.tag {
        case 101:
            model = filterCurrentLogs[indexPath.row]
        case 102:
            model = filterHistoryLogs[indexPath.row]
        default:
            break
        }
        
        guard let model = model else { return nil }

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in

            let copyAction = UIAction(
                title: "复制日志",
                image: UIImage(systemName: "doc.on.doc")
            ) { _ in

                let text =
                "\(model.file)." +
                "\(model.function):" +
                "[\(model.line)]\n" +
                "\(model.message)"

                UIPasteboard.general.string = text

                print("复制成功")
            }

            return UIMenu(
                title: "",
                children: [copyAction]
            )
        }
    }

}

extension FHXLogViewController:FHXNavigationViewDelegate{

    func fhxNavigationView(view:FHXNavigationView, buttonClick button:UIButton) {
        if button.tag == 0 { // pop
            navigationController?.popViewController(animated: true)
        } else if button.tag == 1 {// 当前日志
            
            ToolCurrentPopupView.showCurrentView(
                vc: self,
                menuList: ["筛选", "搜索", "导出", "清空日志"],
                subMenuList: ["All","Debug", "Network", "Error", "Crash"]
            ) {[weak self] value in
                guard let self = self else { return }
                if value == "All" {
                    self.filterCurrentState = .allCurrentFilter
                    applyFilterCurrentData()
                    currentTableView.reloadData()
                } else if value == "Debug" {
                    self.filterCurrentState = .debugCurrentFilter
                    applyFilterCurrentData()
                    currentTableView.reloadData()
                } else if value == "Network" {
                    self.filterCurrentState = .networkCurrentFilter
                    applyFilterCurrentData()
                    currentTableView.reloadData()
                } else if value == "Error" {
                    self.filterCurrentState = .errorCurrentFilter
                    applyFilterCurrentData()
                    currentTableView.reloadData()
                } else if value == "Crash" {
                    self.filterCurrentState = .crashCurrentFilter
                    applyFilterCurrentData()
                    currentTableView.reloadData()
                } else if value == "搜索" {
                    self.navigatonView.isShowSearchCurrentView = true
                } else if value == "导出" {
                    FHXExportView.showCurrentView(
                        array: ["TXT","JSON","取消"],
                        VCView: self.view,
                    ) { [weak self] index in
                        guard let self = self else { return }
                        if index == 0 {
                            do {
                                let url =
                                try FHXLog.shared.exportCurrentLogsTXTFile()
                                let vc =  UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                self.present(vc, animated: true)
                            } catch {
                                print(error)
                            }
                        } else if index == 1 {
                            do {
                                let url =
                                try FHXLog.shared.exportCurrentLogsJSONFile()
                                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                self.present(vc, animated: true)
                            } catch {
                                print(error)
                            }
                        }
                    }
                } else if value == "清空日志" {
                    let alert = UIAlertController(title: "提示", message: "确定清空所有日志吗？", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
                    alert.addAction(
                        UIAlertAction(title: "确定", style: .destructive) { _ in
                            FHXLog.shared.clearCurrentLogs()
                        }
                    )
                    self.present(alert, animated: true)
                }
            }

        } else if button.tag == 2 { //当前日志搜索栏取消按键
            searchCurrent(String())
            searchHistory(String())
        } else if button.tag == 8 { // 历史日志
            UIView.animate(withDuration: 0.25) {
                self.scrollView.contentOffset = CGPoint(
                    x: screenWidthSDK,
                    y: 0
                )
            }
            filterHistoryState = .allHistoryFilter
            searchHistoryTerm = ""
            applyFilterHistoryData()
            historyTableView.reloadData()
        } else if button.tag == 3 { // 筛选
            ToolHistoryPopupView.showCurrentView(
                vc: self,
                totalTopHeight: totalTopHeightSDK(self),
                menuList: ["All", "Debug", "Network", "Error", "Crash"]
            ) { [weak self] value in
                guard let self = self else { return }
                if value == "All" {
                    self.filterHistoryState = .allHistoryFilter
                    applyFilterHistoryData()
                    historyTableView.reloadData()
                } else if value == "Debug" {
                    self.filterHistoryState = .debugHistoryFilter
                    applyFilterHistoryData()
                    historyTableView.reloadData()
                } else if value == "Network" {
                    self.filterHistoryState = .networkHistoryFilter
                    applyFilterHistoryData()
                    historyTableView.reloadData()
                } else if value == "Error" {
                    self.filterHistoryState = .errorHistoryFilter
                    applyFilterHistoryData()
                    historyTableView.reloadData()
                } else if value == "Crash" {
                    self.filterHistoryState = .crashHistoryFilter
                    applyFilterHistoryData()
                    historyTableView.reloadData()
                }
            }
        } else if button.tag == 4 { // 搜索
            self.navigatonView.isShowSearchHistoryView = true
        } else if button.tag == 5 { // 导出
            FHXExportView.showCurrentView(
                array: ["TXT","JSON","取消"],
                VCView: self.view,
            ) { [weak self] index in
                guard let self = self else { return }
                if index == 0 {
                    do {
                        let url =
                        try FHXLog.shared.exportHistoryLogsTXTFile()
                        let vc =  UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        self.present(vc, animated: true)
                    } catch {
                        print(error)
                    }
                } else if index == 1 {
                    do {
                        let url =
                        try FHXLog.shared.exportHistoryLogsJSONFile()
                        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                        self.present(vc, animated: true)
                    } catch {
                        print(error)
                    }
                }
            }
        } else if button.tag == 6{ // 清空日志
            let alert = UIAlertController(title: "提示", message: "确定清空所有日志吗？", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            alert.addAction(
                UIAlertAction(title: "确定", style: .destructive) { _ in
                    FHXLog.shared.clearHistoryLogs()
                }
            )
            self.present(alert, animated: true)
        } else if button.tag == 7{ // 返回
            UIView.animate(withDuration: 0.25) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
            }
        } else if button.tag == 9 {
            let vc = FHXSandboxViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fhxNavigationView(view:FHXNavigationView, searchContent text:String, returnLogType logType:LogType) {
        if logType == .current {
            searchCurrent(text)
        } else if logType == .history {
            searchHistory(text)
        }
    }
    
}
