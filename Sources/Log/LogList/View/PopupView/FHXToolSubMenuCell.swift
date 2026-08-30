

import UIKit

class FHXToolSubMenuCell: UITableViewCell {

    static let identifier = "FHXToolSubMenuCellID"
    
    lazy var titleLabel: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lable.textColor = .black
        return lable
    }()
    
    lazy var line: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 211.0/255.0, green: 211.0/255.0, blue: 211.0/255.0, alpha: 1.0)
        return view
    }()
    
    static func cell(with tableview: UITableView) -> FHXToolSubMenuCell {
        var cell = tableview.dequeueReusableCell(withIdentifier: identifier) as? FHXToolSubMenuCell
        if cell == nil {
            cell = FHXToolSubMenuCell(style: .default, reuseIdentifier: identifier)
        }
        return cell!
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        buildUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func buildUI() {

            selectionStyle = .none
            backgroundColor = .clear

            contentView.addSubview(titleLabel)
            contentView.addSubview(line)

            // 使用系统 Auto Layout
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            line.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([

                // titleLabel
                titleLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 10
                ),

                titleLabel.centerYAnchor.constraint(
                    equalTo: contentView.centerYAnchor
                ),

                // line
                line.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 10
                ),

                line.trailingAnchor.constraint(
                    equalTo: contentView.trailingAnchor
                ),

                line.heightAnchor.constraint(
                    equalToConstant: 1
                ),

                line.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor
                )
            ])
        }
    
}
