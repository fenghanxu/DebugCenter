//
//  FHXJSONClosingCell.swift
//  DebugCenter
//
//  Created by imac on 2026/9/5.
//

// 展开后的状态

import UIKit

final class FHXJSONClosingCell: UITableViewCell {

    static var identifier: String {
        String(describing: self)
    }

    static func cell(
        with tableView: UITableView
    ) -> FHXJSONClosingCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: identifier
            ) as? FHXJSONClosingCell

        return cell
            ?? FHXJSONClosingCell(
                style: .default,
                reuseIdentifier: identifier
            )
    }

    // MARK: - UI

    private lazy var closingLabel: UILabel = {

        let label = UILabel()

        label.font =
            UIFont.monospacedSystemFont(
                ofSize: 13,
                weight: .regular
            )

        label.textColor = .label

        return label
    }()

    // MARK: - Init

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {

        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        selectionStyle = .none

        buildUI()
    }

    required init?(
        coder aDecoder: NSCoder
    ) {

        fatalError(
            "init(coder:) has not been implemented"
        )
    }

    // MARK: - UI

    private func buildUI() {

        contentView.addSubview(
            closingLabel
        )

        closingLabel.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([

            closingLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            closingLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            closingLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])
    }

    // MARK: - Config

    func setNode(
        _ node: FHXJSONNode
    ) {

        let indentation =
            String(
                repeating: " ",
                count: node.depth * 4
            )

        closingLabel.text =
            indentation
            + node.value.closingSymbol
    }
}
