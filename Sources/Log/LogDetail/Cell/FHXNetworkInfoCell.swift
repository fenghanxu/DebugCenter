//
//  FHXNetworkInfoCell.swift
//  DebugCenter
//
//  Created by imac on 2026/9/6.
//

import UIKit

final class FHXNetworkInfoCell: UITableViewCell {

    static var identifier: String {
        String(describing: self)
    }

    static func cell(
        with tableView: UITableView
    ) -> FHXNetworkInfoCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: identifier
            ) as? FHXNetworkInfoCell

        return cell
            ?? FHXNetworkInfoCell(
                style: .default,
                reuseIdentifier: identifier
            )
    }

    // MARK: - UI

    private lazy var titleLabel: UILabel = {

        let label = UILabel()

        label.font =
            UIFont.systemFont(
                ofSize: 13,
                weight: .medium
            )

        label.textColor =
            .secondaryLabel

        return label
    }()

    private lazy var valueLabel: UILabel = {

        let label = UILabel()

        label.font =
            UIFont.monospacedSystemFont(
                ofSize: 13,
                weight: .regular
            )

        label.textColor =
            .label

        label.numberOfLines = 0

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
            titleLabel
        )

        contentView.addSubview(
            valueLabel
        )

        titleLabel.translatesAutoresizingMaskIntoConstraints =
            false

        valueLabel.translatesAutoresizingMaskIntoConstraints =
            false

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 8
            ),

            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            valueLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: 3
            ),

            valueLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            valueLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            valueLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -8
            )
        ])
    }

    // MARK: - Config

    func setData(
        title: String,
        value: String
    ) {

        titleLabel.text = title

        valueLabel.text =
            value.isEmpty
            ? "-"
            : value
    }
    
    func setTitle(
        _ title: String
    ) {
        titleLabel.text = title
        valueLabel.text = nil
    }
    
}
