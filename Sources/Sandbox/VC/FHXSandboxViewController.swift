//
//  FHXSandboxViewController.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/21.
//

import UIKit

final class FHXSandboxViewController: UIViewController {

    // MARK: - Property

    /// 当前目录，nil 表示根目录
    private let currentPath: String?

    /// 当前显示的数据
    private var dataSource: [FHXSandboxModel] = []

    private lazy var tableView: UITableView = {

        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )

        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 60

        tableView.register(
            FHXSandboxCell.self,
            forCellReuseIdentifier: FHXSandboxCell.reuseIdentifier
        )

        return tableView
    }()

    // MARK: - Init

    init(path: String? = nil) {

        self.currentPath = path

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .white

        buildUI()

        loadData()
    }
}

// MARK: - UI

private extension FHXSandboxViewController {

    func buildUI() {

        view.addSubview(tableView)

        tableView.frame = view.bounds
        tableView.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
    }
}

// MARK: - Data

private extension FHXSandboxViewController {

    func loadData() {

        if let path = currentPath {

            title = (path as NSString).lastPathComponent

            dataSource = FHXSandboxManager.shared.contents(
                at: path
            )

        } else {

            title = "Sandbox"

            dataSource = FHXSandboxManager.shared.rootItems()
        }

        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension FHXSandboxViewController: UITableViewDataSource {

    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {

        dataSource.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell =
        tableView.dequeueReusableCell(
            withIdentifier: FHXSandboxCell.reuseIdentifier,
            for: indexPath
        ) as! FHXSandboxCell
        
        cell.config(model: dataSource[indexPath.row])

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FHXSandboxViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {

        tableView.deselectRow(at: indexPath, animated: true)

        let model = dataSource[indexPath.row]

        if model.isDirectory {
            let vc = FHXSandboxViewController(path: model.path)
            navigationController?.pushViewController(vc,animated: true)
        } else {

            navigationController?.pushViewController(
                FHXSandboxPreviewController(
                    model: model
                ),
                animated: true
            )

        }
    }
}



