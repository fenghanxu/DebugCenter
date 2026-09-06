//
//  FHXDetailViewController.swift
//  DebugCenter
//
//  Created by imac on 2026/8/15.
//

import UIKit

class FHXDetailViewController: UIViewController {

    // MARK: - Property

    var model: FHXLogModel?

    private var networkInfo:
        FHXNetworkLogInfo?

    private var rootNode:
        FHXJSONNode?

    private var visibleRows:
        [FHXJSONRow] = []

    // MARK: - UI

    private lazy var navigationView:
        FHXCurrentNavigationView = {

        let view =
            FHXCurrentNavigationView()

        view.delegate = self

        view.backgroundColor =
            .white

        return view
    }()

    private lazy var tableView:
        UITableView = {

        let tableView =
            UITableView(
                frame: .zero,
                style: .plain
            )

        tableView.backgroundColor =
            .white

        tableView.separatorStyle =
            .none

        tableView.showsVerticalScrollIndicator =
            true

        tableView.rowHeight =
            28

        tableView.estimatedRowHeight =
            28

        tableView.delegate =
            self

        tableView.dataSource =
            self

        tableView.register(
            FHXJSONTreeCell.self,
            forCellReuseIdentifier:
                FHXJSONTreeCell.identifier
        )

        tableView.register(
            FHXJSONClosingCell.self,
            forCellReuseIdentifier:
                FHXJSONClosingCell.identifier
        )

        tableView.register(
            FHXNetworkInfoCell.self,
            forCellReuseIdentifier:
                FHXNetworkInfoCell.identifier
        )

        return tableView
    }()

    private lazy var textView:
        UITextView = {

        let textView =
            UITextView()

        textView.backgroundColor =
            .white

        textView.font =
            UIFont.monospacedSystemFont(
                ofSize: 13,
                weight: .regular
            )

        textView.textColor =
            .label

        textView.isEditable =
            false

        textView.isSelectable =
            true

        textView.showsVerticalScrollIndicator =
            true

        textView.alwaysBounceVertical =
            true

        textView.textContainerInset =
            UIEdgeInsets(
                top: 10,
                left: 10,
                bottom: 10,
                right: 10
            )

        return textView
    }()

    private lazy var loadingIndicator:
        UIActivityIndicatorView = {

        let view =
            UIActivityIndicatorView(
                style: .medium
            )

        view.hidesWhenStopped =
            true

        return view
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        buildUI()

        if let model {

            setModel(model)
        }

        navigationController?
            .interactivePopGestureRecognizer?
            .delegate = nil
    }

    override func viewWillAppear(
        _ animated: Bool
    ) {

        super.viewWillAppear(
            animated
        )

        navigationController?
            .setNavigationBarHidden(
                true,
                animated: animated
            )
    }

    override func viewWillDisappear(
        _ animated: Bool
    ) {

        super.viewWillDisappear(
            animated
        )

        navigationController?
            .setNavigationBarHidden(
                false,
                animated: animated
            )
    }

    // MARK: - UI Setup

    private func buildUI() {

        view.backgroundColor =
            .white

        view.addSubview(
            navigationView
        )

        view.addSubview(
            tableView
        )

        view.addSubview(
            textView
        )

        view.addSubview(
            loadingIndicator
        )

        navigationView.translatesAutoresizingMaskIntoConstraints =
            false

        tableView.translatesAutoresizingMaskIntoConstraints =
            false

        textView.translatesAutoresizingMaskIntoConstraints =
            false

        loadingIndicator.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([

            // MARK: Navigation

            navigationView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            navigationView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            navigationView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            navigationView.heightAnchor.constraint(
                equalToConstant:
                    safeAreaTopSDK + 44
            ),

            // MARK: TableView

            tableView.topAnchor.constraint(
                equalTo: navigationView.bottomAnchor
            ),

            tableView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            tableView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            tableView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // MARK: TextView

            textView.topAnchor.constraint(
                equalTo: navigationView.bottomAnchor
            ),

            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // MARK: Loading

            loadingIndicator.centerXAnchor.constraint(
                equalTo: tableView.centerXAnchor
            ),

            loadingIndicator.centerYAnchor.constraint(
                equalTo: tableView.centerYAnchor
            )
        ])

        /*
         默认隐藏 TextView。

         真正解析失败的时候才显示。
         */
        textView.isHidden = true
    }

    // MARK: - Model

    private func setModel(
        _ model: FHXLogModel
    ) {

        navigationView.setData(
            model.message
        )

        loadingIndicator.startAnimating()

        let message =
            model.message

        // JSON / 网络日志解析放后台

        DispatchQueue.global(
            qos: .userInitiated
        ).async { [weak self] in

            guard let self else {
                return
            }

            let info =
                FHXJSONParser.parseNetworkLog(
                    message
                )

            DispatchQueue.main.async {

                self.loadingIndicator
                    .stopAnimating()

                /*
                 先判断是不是能够按照
                 网络日志 + JSON Tree 的方式解析。
                 */
                if let responseNode =
                    info.responseNode {

                    // MARK: 网络日志

                    self.networkInfo =
                        info

                    self.rootNode =
                        responseNode

                    /*
                     根节点默认展开
                     */
                    responseNode.isExpanded =
                        true

                    self.rebuildVisibleRows()

                    /*
                     显示 UITableView
                     */
                    self.tableView.isHidden =
                        false

                    self.textView.isHidden =
                        true

                    self.tableView.reloadData()

                } else {

                    // MARK: 普通长文本

                    /*
                     无法解析成网络日志。

                     不再使用 UITableView。

                     直接把原始数据放进 UITextView。
                     */

                    self.networkInfo =
                        nil

                    self.rootNode =
                        nil

                    self.visibleRows =
                        []

                    self.tableView.isHidden =
                        true

                    self.textView.isHidden =
                        false

                    self.textView.text =
                        message
                }
            }
        }
    }

    // MARK: - Visible Rows

    private func rebuildVisibleRows() {

        guard
            let rootNode
        else {

            visibleRows = []

            return
        }

        var rows:
            [FHXJSONRow] = []

        appendVisibleRows(
            node: rootNode,
            rows: &rows
        )

        visibleRows =
            rows
    }

    private func appendVisibleRows(
        node: FHXJSONNode,
        rows: inout [FHXJSONRow]
    ) {

        rows.append(
            .node(node)
        )

        guard
            node.isContainer,
            node.isExpanded
        else {

            return
        }

        for child
            in node.children {

            appendVisibleRows(
                node: child,
                rows: &rows
            )
        }

        rows.append(
            .closing(node)
        )
    }

    // MARK: - Toggle

    private func toggle(
        node: FHXJSONNode
    ) {

        guard
            node.isContainer
        else {

            return
        }

        node.isExpanded.toggle()

        rebuildVisibleRows()

        tableView.reloadData()
    }

    // MARK: - Expand All

    private func expandAll(
        node: FHXJSONNode
    ) {

        node.isExpanded = true

        for child
            in node.children {

            expandAll(
                node: child
            )
        }
    }

    // MARK: - Collapse All

    private func collapseAll(
        node: FHXJSONNode
    ) {

        node.isExpanded = false

        for child
            in node.children {

            collapseAll(
                node: child
            )
        }
    }
}

// MARK: - UITableViewDataSource

extension FHXDetailViewController:
    UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        guard
            networkInfo != nil
        else {

            return 0
        }

        /*
         网络信息：

         0  Method
         1  URL
         2  StatusCode
         3  CostTime
         4  Error
         5  Headers
         6  Parameters
         7  Response

         再加 JSON Tree
         */

        return 8 + visibleRows.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        guard
            let networkInfo
        else {

            return UITableViewCell()
        }

        // MARK: Network Info

        if indexPath.row < 8 {

            let cell =
                FHXNetworkInfoCell.cell(
                    with: tableView
                )

            switch indexPath.row {

            case 0:

                cell.setData(
                    title: "Method",
                    value:
                        networkInfo.method
                )

            case 1:

                cell.setData(
                    title: "URL",
                    value:
                        networkInfo.url
                )

            case 2:

                cell.setData(
                    title: "StatusCode",
                    value:
                        networkInfo.statusCode
                )

            case 3:

                cell.setData(
                    title: "CostTime",
                    value:
                        networkInfo.costTime
                )

            case 4:

                cell.setData(
                    title: "Error",
                    value:
                        networkInfo.error
                )

            case 5:

                cell.setData(
                    title: "Headers",
                    value:
                        networkInfo.headers
                )

            case 6:

                cell.setData(
                    title: "Parameters",
                    value:
                        networkInfo.parameters
                )

            case 7:

                /*
                 Response 标题。

                 只显示灰色的 Response。
                 */

                cell.setTitle(
                    "Response"
                )

            default:
                break
            }

            return cell
        }

        // MARK: JSON

        let jsonIndex =
            indexPath.row - 8

        guard
            jsonIndex >= 0,
            jsonIndex < visibleRows.count
        else {

            return UITableViewCell()
        }

        let row =
            visibleRows[jsonIndex]

        switch row {

        case .node(let node):

            let cell =
                FHXJSONTreeCell.cell(
                    with: tableView
                )

            cell.setNode(
                node
            ) { [weak self, weak node] in

                guard
                    let self,
                    let node
                else {

                    return
                }

                self.toggle(
                    node: node
                )
            }

            return cell

        case .closing(let node):

            let cell =
                FHXJSONClosingCell.cell(
                    with: tableView
                )

            cell.setNode(
                node
            )

            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension FHXDetailViewController:
    UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        /*
         前 8 个都是网络信息，
         从第 8 个开始才是 JSON。
         */

        guard
            indexPath.row >= 8
        else {

            return
        }

        let jsonIndex =
            indexPath.row - 8

        guard
            jsonIndex >= 0,
            jsonIndex < visibleRows.count
        else {

            return
        }

        let row =
            visibleRows[jsonIndex]

        guard
            case .node(let node) = row
        else {

            return
        }

        toggle(
            node: node
        )
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {

        if indexPath.row < 8 {

            /*
             Method / URL / Headers /
             Parameters / Response 等
             使用自动高度。
             */

            return UITableView.automaticDimension
        }

        /*
         JSON Tree 固定高度。
         */

        return 28
    }
}

// MARK: - JSON Row

private enum FHXJSONRow {

    case node(FHXJSONNode)

    case closing(FHXJSONNode)
}

// MARK: - Navigation

extension FHXDetailViewController:
    FHXCurrentNavigationViewDelegate {

    func fhxCurrentNavigationView(
        view: FHXCurrentNavigationView,
        buttonClick: UIButton
    ) {

        navigationController?.popViewController(
            animated: true
        )
    }
}

//import UIKit
//
//class FHXDetailViewController: UIViewController {
//
//    // MARK: - Property
//
//    var model: FHXLogModel?
//
//    private var networkInfo:
//        FHXNetworkLogInfo?
//
//    private var rootNode:
//        FHXJSONNode?
//
//    private var visibleRows:
//        [FHXJSONRow] = []
//
//    // MARK: - UI
//
//    private lazy var navigationView:
//        FHXCurrentNavigationView = {
//
//        let view =
//            FHXCurrentNavigationView()
//
//        view.delegate = self
//
//        view.backgroundColor =
//            .white
//
//        return view
//    }()
//
//    private lazy var tableView:
//        UITableView = {
//
//        let tableView =
//            UITableView(
//                frame: .zero,
//                style: .plain
//            )
//
//        tableView.backgroundColor =
//            .white
//
//        tableView.separatorStyle =
//            .none
//
//        tableView.showsVerticalScrollIndicator =
//            true
//
//        tableView.rowHeight =
//            28
//
//        tableView.estimatedRowHeight =
//            28
//
//        tableView.delegate =
//            self
//
//        tableView.dataSource =
//            self
//
//        tableView.register(
//            FHXJSONTreeCell.self,
//            forCellReuseIdentifier:
//                FHXJSONTreeCell.identifier
//        )
//
//        tableView.register(
//            FHXJSONClosingCell.self,
//            forCellReuseIdentifier:
//                FHXJSONClosingCell.identifier
//        )
//
//        tableView.register(
//            FHXNetworkInfoCell.self,
//            forCellReuseIdentifier:
//                FHXNetworkInfoCell.identifier
//        )
//
//        return tableView
//    }()
//
//    private lazy var loadingIndicator:
//        UIActivityIndicatorView = {
//
//        let view =
//            UIActivityIndicatorView(
//                style: .medium
//            )
//
//        view.hidesWhenStopped =
//            true
//
//        return view
//    }()
//
//    // MARK: - Life Cycle
//
//    override func viewDidLoad() {
//
//        super.viewDidLoad()
//
//        buildUI()
//
//        if let model {
//
//            setModel(model)
//        }
//
//        navigationController?
//            .interactivePopGestureRecognizer?
//            .delegate = nil
//    }
//
//    override func viewWillAppear(
//        _ animated: Bool
//    ) {
//
//        super.viewWillAppear(
//            animated
//        )
//
//        navigationController?
//            .setNavigationBarHidden(
//                true,
//                animated: animated
//            )
//    }
//
//    override func viewWillDisappear(
//        _ animated: Bool
//    ) {
//
//        super.viewWillDisappear(
//            animated
//        )
//
//        navigationController?
//            .setNavigationBarHidden(
//                false,
//                animated: animated
//            )
//    }
//
//    // MARK: - UI Setup
//
//    private func buildUI() {
//
//        view.backgroundColor =
//            .white
//
//        view.addSubview(
//            navigationView
//        )
//
//        view.addSubview(
//            tableView
//        )
//
//        view.addSubview(
//            loadingIndicator
//        )
//
//        navigationView.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        tableView.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        loadingIndicator.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        NSLayoutConstraint.activate([
//
//            // MARK: Navigation
//
//            navigationView.leadingAnchor.constraint(
//                equalTo: view.leadingAnchor
//            ),
//
//            navigationView.trailingAnchor.constraint(
//                equalTo: view.trailingAnchor
//            ),
//
//            navigationView.topAnchor.constraint(
//                equalTo: view.topAnchor
//            ),
//
//            navigationView.heightAnchor.constraint(
//                equalToConstant:
//                    safeAreaTopSDK + 44
//            ),
//
//            // MARK: TableView
//
//            tableView.topAnchor.constraint(
//                equalTo: navigationView.bottomAnchor
//            ),
//
//            tableView.leadingAnchor.constraint(
//                equalTo: view.leadingAnchor
//            ),
//
//            tableView.trailingAnchor.constraint(
//                equalTo: view.trailingAnchor
//            ),
//
//            tableView.bottomAnchor.constraint(
//                equalTo: view.bottomAnchor
//            ),
//
//            // MARK: Loading
//
//            loadingIndicator.centerXAnchor.constraint(
//                equalTo: tableView.centerXAnchor
//            ),
//
//            loadingIndicator.centerYAnchor.constraint(
//                equalTo: tableView.centerYAnchor
//            )
//        ])
//    }
//
//    // MARK: - Model
//
//    private func setModel(
//        _ model: FHXLogModel
//    ) {
//
//        navigationView.setData(
//            model.message
//        )
//
//        loadingIndicator.startAnimating()
//
//        let message =
//            model.message
//
//        // JSON / 网络日志解析放后台
//
//        DispatchQueue.global(
//            qos: .userInitiated
//        ).async { [weak self] in
//
//            guard let self else {
//                return
//            }
//
//            let info =
//                FHXJSONParser.parseNetworkLog(
//                    message
//                )
//
//            DispatchQueue.main.async {
//
//                self.loadingIndicator
//                    .stopAnimating()
//
//                self.networkInfo =
//                    info
//
//                self.rootNode =
//                    info.responseNode
//
//                if let rootNode =
//                    info.responseNode {
//
//                    // 根节点默认展开
//
//                    rootNode.isExpanded =
//                        true
//
//                    self.rebuildVisibleRows()
//
//                } else {
//
//                    // Response 不是 JSON
//
//                    self.visibleRows = []
//                }
//
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    // MARK: - Visible Rows
//
//    private func rebuildVisibleRows() {
//
//        guard
//            let rootNode
//        else {
//
//            visibleRows = []
//
//            return
//        }
//
//        var rows:
//            [FHXJSONRow] = []
//
//        appendVisibleRows(
//            node: rootNode,
//            rows: &rows
//        )
//
//        visibleRows =
//            rows
//    }
//
//    private func appendVisibleRows(
//        node: FHXJSONNode,
//        rows: inout [FHXJSONRow]
//    ) {
//
//        rows.append(
//            .node(node)
//        )
//
//        guard
//            node.isContainer,
//            node.isExpanded
//        else {
//
//            return
//        }
//
//        for child
//            in node.children {
//
//            appendVisibleRows(
//                node: child,
//                rows: &rows
//            )
//        }
//
//        rows.append(
//            .closing(node)
//        )
//    }
//
//    // MARK: - Toggle
//
//    private func toggle(
//        node: FHXJSONNode
//    ) {
//
//        guard
//            node.isContainer
//        else {
//
//            return
//        }
//
//        node.isExpanded.toggle()
//
//        rebuildVisibleRows()
//
//        tableView.reloadData()
//    }
//
//    // MARK: - Expand All
//
//    private func expandAll(
//        node: FHXJSONNode
//    ) {
//
//        node.isExpanded = true
//
//        for child
//            in node.children {
//
//            expandAll(
//                node: child
//            )
//        }
//    }
//
//    // MARK: - Collapse All
//
//    private func collapseAll(
//        node: FHXJSONNode
//    ) {
//
//        node.isExpanded = false
//
//        for child
//            in node.children {
//
//            collapseAll(
//                node: child
//            )
//        }
//    }
//}
//
//// MARK: - UITableViewDataSource
//
//extension FHXDetailViewController:
//    UITableViewDataSource {
//
//    func tableView(
//        _ tableView: UITableView,
//        numberOfRowsInSection section: Int
//    ) -> Int {
//
//        guard
//            networkInfo != nil
//        else {
//
//            return 0
//        }
//
//        /*
//         网络信息：
//
//         0  Method
//         1  URL
//         2  StatusCode
//         3  CostTime
//         4  Error
//         5  Headers
//         6  Parameters
//         7  Response
//
//         再加 JSON Tree
//         */
//
//        return 8 + visibleRows.count
//    }
//
//    func tableView(
//        _ tableView: UITableView,
//        cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
//
//        guard
//            let networkInfo
//        else {
//
//            return UITableViewCell()
//        }
//
//        // MARK: Network Info
//
//        if indexPath.row < 8 {
//
//            let cell =
//                FHXNetworkInfoCell.cell(
//                    with: tableView
//                )
//
//            switch indexPath.row {
//
//            case 0:
//
//                cell.setData(
//                    title: "Method",
//                    value:
//                        networkInfo.method
//                )
//
//            case 1:
//
//                cell.setData(
//                    title: "URL",
//                    value:
//                        networkInfo.url
//                )
//
//            case 2:
//
//                cell.setData(
//                    title: "StatusCode",
//                    value:
//                        networkInfo.statusCode
//                )
//
//            case 3:
//
//                cell.setData(
//                    title: "CostTime",
//                    value:
//                        networkInfo.costTime
//                )
//
//            case 4:
//
//                cell.setData(
//                    title: "Error",
//                    value:
//                        networkInfo.error
//                )
//
//            case 5:
//
//                cell.setData(
//                    title: "Headers",
//                    value:
//                        networkInfo.headers
//                )
//
//            case 6:
//
//                cell.setData(
//                    title: "Parameters",
//                    value:
//                        networkInfo.parameters
//                )
//
//            case 7:
//
//                /*
//                 Response 标题。
//
//                 这里不显示实际 JSON 内容，
//                 只显示一个灰色的 Response 标题。
//
//                 实际 JSON 从下面的 Tree Cell 开始。
//                 */
//
//                cell.setTitle("Response")
//
//            default:
//
//                break
//            }
//
//            return cell
//        }
//
//        // MARK: JSON
//
//        let jsonIndex =
//            indexPath.row - 8
//
//        guard
//            jsonIndex >= 0,
//            jsonIndex < visibleRows.count
//        else {
//
//            return UITableViewCell()
//        }
//
//        let row =
//            visibleRows[jsonIndex]
//
//        switch row {
//
//        case .node(let node):
//
//            let cell =
//                FHXJSONTreeCell.cell(
//                    with: tableView
//                )
//
//            cell.setNode(
//                node
//            ) { [weak self, weak node] in
//
//                guard
//                    let self,
//                    let node
//                else {
//
//                    return
//                }
//
//                self.toggle(
//                    node: node
//                )
//            }
//
//            return cell
//
//        case .closing(let node):
//
//            let cell =
//                FHXJSONClosingCell.cell(
//                    with: tableView
//                )
//
//            cell.setNode(
//                node
//            )
//
//            return cell
//        }
//    }
//}
//
//// MARK: - UITableViewDelegate
//
//extension FHXDetailViewController:
//    UITableViewDelegate {
//
//    func tableView(
//        _ tableView: UITableView,
//        didSelectRowAt indexPath: IndexPath
//    ) {
//
//        /*
//         前 8 个都是网络信息，
//         从第 8 个开始才是 JSON。
//         */
//
//        guard
//            indexPath.row >= 8
//        else {
//
//            return
//        }
//
//        let jsonIndex =
//            indexPath.row - 8
//
//        guard
//            jsonIndex >= 0,
//            jsonIndex < visibleRows.count
//        else {
//
//            return
//        }
//
//        let row =
//            visibleRows[jsonIndex]
//
//        guard
//            case .node(let node) = row
//        else {
//
//            return
//        }
//
//        toggle(
//            node: node
//        )
//    }
//
//    func tableView(
//        _ tableView: UITableView,
//        heightForRowAt indexPath: IndexPath
//    ) -> CGFloat {
//
//        if indexPath.row < 8 {
//
//            /*
//             Method / URL / Headers /
//             Parameters / Response 等
//             使用自动高度。
//             */
//
//            return UITableView.automaticDimension
//        }
//
//        /*
//         JSON Tree 固定高度。
//         */
//
//        return 28
//    }
//}
//
//// MARK: - JSON Row
//
//private enum FHXJSONRow {
//
//    case node(FHXJSONNode)
//
//    case closing(FHXJSONNode)
//}
//
//// MARK: - Navigation
//
//extension FHXDetailViewController:
//    FHXCurrentNavigationViewDelegate {
//
//    func fhxCurrentNavigationView(
//        view: FHXCurrentNavigationView,
//        buttonClick: UIButton
//    ) {
//
//        navigationController?.popViewController(
//            animated: true
//        )
//    }
//}
//
