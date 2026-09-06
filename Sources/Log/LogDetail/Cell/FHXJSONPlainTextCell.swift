//
//  FHXJSONPlainTextCell.swift
//  DebugCenter
//
//  Created by imac on 2026/9/5.
//


import UIKit

final class FHXJSONPlainTextCell: UITableViewCell {

    static var identifier: String {

        String(describing: self)
    }

    static func cell(
        with tableView: UITableView
    ) -> FHXJSONPlainTextCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: identifier
        ) as? FHXJSONPlainTextCell

        return cell ?? FHXJSONPlainTextCell(
            style: .default,
            reuseIdentifier: identifier
        )
    }

    // MARK: - UI

    private lazy var textLabelView: UILabel = {

        let label = UILabel()

        label.font = UIFont.monospacedSystemFont(
            ofSize: 13,
            weight: .regular
        )

        label.numberOfLines = 1

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

        contentView.addSubview(textLabelView)

        textLabelView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            textLabelView.topAnchor.constraint(
                equalTo: contentView.topAnchor
            ),

            textLabelView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            textLabelView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            textLabelView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            )
        ])
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Config

    func setText(
        _ text: String
    ) {

        textLabelView.text = text
    }
}

