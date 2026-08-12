

import UIKit

protocol FHXToolMenuViewDelegate:NSObjectProtocol {
    func fhxToolMenuView(model:FHXToolMenuView, didSelectRowAt indexPath: IndexPath)
}

class FHXToolMenuView: UIView {
    
    weak var delegate: FHXToolMenuViewDelegate?
    
    var list:[String] = [String]()
    
    lazy private var tableView: UITableView = {
        var tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.bounces = false
        tableView.rowHeight = 44
        tableView.register(FHXToolMenuCell.self, forCellReuseIdentifier: FHXToolMenuCell.identifier)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        tableView.sectionHeaderHeight = CGFloat.leastNormalMagnitude
        tableView.estimatedRowHeight = 0.0;
        tableView.estimatedSectionFooterHeight = 0.0
        tableView.estimatedSectionHeaderHeight = 0.0
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buileUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buileUI() {
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}

extension FHXToolMenuView: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FHXToolMenuCell = FHXToolMenuCell.cell(with: tableView)
        cell.titleLabel.text = list[indexPath.item]
        cell.line.isHidden = indexPath.item == list.count - 1 ? true : false
        cell.rightArrow.isHidden = list[indexPath.item] == "筛选" ?  false : true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.fhxToolMenuView(model: self, didSelectRowAt: indexPath)
    }
}

