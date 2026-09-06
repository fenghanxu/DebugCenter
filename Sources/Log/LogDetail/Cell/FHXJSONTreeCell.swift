//
//  FHXJSONTreeCell.swift
//  DebugCenter
//
//  Created by imac on 2026/9/5.
//

// 折叠状态

import UIKit

final class FHXJSONTreeCell: UITableViewCell {

    static var identifier: String {
        String(describing: self)
    }

    static func cell(
        with tableView: UITableView
    ) -> FHXJSONTreeCell {

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: identifier
            ) as? FHXJSONTreeCell

        return cell
            ?? FHXJSONTreeCell(
                style: .default,
                reuseIdentifier: identifier
            )
    }

    // MARK: - UI

    private lazy var toggleButton: UIButton = {

        let button = UIButton()

        button.layer.cornerRadius = 4
        button.clipsToBounds = true

        return button
    }()

    private lazy var keyLabel: UILabel = {

        let label = UILabel()

        label.font =
            UIFont.monospacedSystemFont(
                ofSize: 13,
                weight: .regular
            )

        label.numberOfLines = 1

        label.lineBreakMode =
            .byTruncatingTail

        label.textColor = UIColor(
            red: 154.0 / 255.0,
            green: 60.0 / 255.0,
            blue: 153.0 / 255.0,
            alpha: 1.0
        )

        return label
    }()

    private lazy var valueLabel: UILabel = {

        let label = UILabel()

        label.font =
            UIFont.monospacedSystemFont(
                ofSize: 13,
                weight: .regular
            )

        label.numberOfLines = 1

        label.lineBreakMode =
            .byTruncatingTail

        return label
    }()

    // MARK: - Constraint

    private var toggleLeadingConstraint:
        NSLayoutConstraint?

    /*
     toggleButton → keyLabel
     */
    private var keyLeadingConstraint:
        NSLayoutConstraint?

    /*
     keyLabel → valueLabel
     */
    private var valueLeadingConstraint:
        NSLayoutConstraint?

    /*
     根节点 keyLabel 宽度。

     普通节点：
     >= 20

     根节点：
     0
     */
    private var keyWidthConstraint:
        NSLayoutConstraint?

    // MARK: - Property

    private var toggleAction:
        (() -> Void)?

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

    override func prepareForReuse() {

        super.prepareForReuse()

        toggleAction = nil

        keyLabel.text = nil

        valueLabel.text = nil

        valueLabel.textColor = .label

        keyLabel.isHidden = false

        toggleButton.isHidden = false

        toggleButton.setImage(
            nil,
            for: .normal
        )

        toggleLeadingConstraint?.constant = 5

        /*
         默认恢复普通节点。
         */
        keyWidthConstraint?.constant = 20
    }

    // MARK: - UI

    private func buildUI() {

        contentView.addSubview(
            toggleButton
        )

        contentView.addSubview(
            keyLabel
        )

        contentView.addSubview(
            valueLabel
        )

        toggleButton.translatesAutoresizingMaskIntoConstraints =
            false

        keyLabel.translatesAutoresizingMaskIntoConstraints =
            false

        valueLabel.translatesAutoresizingMaskIntoConstraints =
            false

        // MARK: Toggle Leading

        toggleLeadingConstraint =
            toggleButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 5
            )

        // MARK: Key Leading

        keyLeadingConstraint =
            keyLabel.leadingAnchor.constraint(
                equalTo: toggleButton.trailingAnchor
            )

        // MARK: Value Leading

        valueLeadingConstraint =
            valueLabel.leadingAnchor.constraint(
                equalTo: keyLabel.trailingAnchor,
                constant: 5
            )

        // MARK: Key Width

        keyWidthConstraint =
            keyLabel.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 20
            )

        guard
            let toggleLeadingConstraint,
            let keyLeadingConstraint,
            let valueLeadingConstraint,
            let keyWidthConstraint
        else {
            return
        }

        NSLayoutConstraint.activate([

            // MARK: Toggle

            toggleLeadingConstraint,

            toggleButton.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            toggleButton.widthAnchor.constraint(
                equalToConstant: 24
            ),

            toggleButton.heightAnchor.constraint(
                equalToConstant: 24
            ),

            // MARK: Key

            keyLeadingConstraint,

            keyLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            ),

            keyWidthConstraint,

            // MARK: Value

            valueLeadingConstraint,

            valueLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: contentView.trailingAnchor,
                constant: -10
            ),

            valueLabel.centerYAnchor.constraint(
                equalTo: contentView.centerYAnchor
            )
        ])

        // MARK: Priority

        keyLabel.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )

        keyLabel.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal
        )

        valueLabel.setContentHuggingPriority(
            .defaultLow,
            for: .horizontal
        )

        valueLabel.setContentCompressionResistancePriority(
            .defaultLow,
            for: .horizontal
        )

        // MARK: Action

        toggleButton.addTarget(
            self,
            action: #selector(
                toggleButtonClick
            ),
            for: .touchUpInside
        )
    }

    // MARK: - Config

    func setNode(
        _ node: FHXJSONNode,
        toggleAction: @escaping () -> Void
    ) {

        self.toggleAction =
            toggleAction

        // MARK: Indentation

        let indentation =
            CGFloat(node.depth * 18)

        /*
         JSON 层级缩进：

         第 0 层：5
         第 1 层：23
         第 2 层：41
         第 3 层：59

         每一级增加 18pt。
         */

        toggleLeadingConstraint?.constant =
            5 + indentation

        // MARK: Root / Normal Node

        if node.key == "root" {

            /*
             根节点没有 key。

             目标：

             - {
             - [

             折叠：

             + {...}
             + [...]

             最终布局：

             toggleButton
                    ↓
                   5pt
                    ↓
               valueLabel

             通过让 keyLabel 宽度变成 0
             实现视觉上的直接连接。
             */

            keyLabel.text = ""

            keyLabel.isHidden = true

            /*
             关键：

             根节点 keyLabel 宽度 = 0

             不再使用 >= 20。
             */
            keyWidthConstraint?.constant = 0

            /*
             根节点 valueLabel：

             toggleButton
                    ↓
                   0
                    ↓
             keyLabel(0宽)
                    ↓
                   5
                    ↓
             valueLabel

             实际视觉距离就是 5pt。
             */

            valueLeadingConstraint?.constant = 5

        } else {

            /*
             普通节点：

             - "data": {
             - "list": [
             - "code": 0

             正常显示 keyLabel。
             */

            keyLabel.isHidden = false

            /*
             恢复 keyLabel 最小宽度。
             */
            keyWidthConstraint?.constant = 20

            /*
             keyLabel → valueLabel
             */
            valueLeadingConstraint?.constant = 5

            if node.key.hasPrefix("[") {

                keyLabel.text =
                    node.key

            } else {

                keyLabel.text =
                    "\"\(node.key)\":"
            }
        }

        // MARK: Toggle Button

        if node.isContainer {

            toggleButton.isHidden =
                false

            let frameworkBundle =
                Bundle(
                    for: FHXJSONTreeCell.self
                )

            if
                let bundleURL =
                    frameworkBundle.url(
                        forResource: "file",
                        withExtension: "bundle"
                    ),
                let sdkBundle =
                    Bundle(
                        url: bundleURL
                    )
            {

                let addImage =
                    UIImage(
                        named: "add",
                        in: sdkBundle,
                        compatibleWith: nil
                    )

                let reduceImage =
                    UIImage(
                        named: "reduce",
                        in: sdkBundle,
                        compatibleWith: nil
                    )

                toggleButton.setImage(
                    node.isExpanded
                        ? reduceImage
                        : addImage,
                    for: .normal
                )
            }

        } else {

            /*
             普通值没有 +/- 按钮。
             */

            toggleButton.isHidden =
                true

            toggleButton.setImage(
                nil,
                for: .normal
            )
        }

        // MARK: Value

        configureValue(
            node.value,
            isExpanded: node.isExpanded
        )
    }

    // MARK: - Value

    private func configureValue(
        _ value: FHXJSONValue,
        isExpanded: Bool
    ) {

        switch value {

        case .dictionary:

            /*
             展开：

             - {

             折叠：

             + {...}
             */

            valueLabel.text =
                isExpanded
                    ? "{"
                    : "{...}"

            valueLabel.textColor =
                .label

        case .array:

            /*
             展开：

             - [

             折叠：

             + [...]
             */

            valueLabel.text =
                isExpanded
                    ? "["
                    : "[...]"

            valueLabel.textColor =
                .label

        case .string(let value):

            valueLabel.text =
                "\"\(value)\""

            valueLabel.textColor = UIColor(
                red: 0.0 / 255.0,
                green: 144.0 / 255.0,
                blue: 109.0 / 255.0,
                alpha: 1.0
            )

        case .integer(let value):

            valueLabel.text =
                "\(value)"

            valueLabel.textColor = UIColor(
                red: 61.0 / 255.0,
                green: 174.0 / 255.0,
                blue: 227.0 / 255.0,
                alpha: 1.0
            )

        case .double(let value):

            valueLabel.text =
                "\(value)"

            valueLabel.textColor = UIColor(
                red: 61.0 / 255.0,
                green: 174.0 / 255.0,
                blue: 227.0 / 255.0,
                alpha: 1.0
            )

        case .bool(let value):

            valueLabel.text =
                value
                    ? "true"
                    : "false"

            valueLabel.textColor = UIColor(
                red: 247.0 / 255.0,
                green: 144.0 / 255.0,
                blue: 142.0 / 255.0,
                alpha: 1.0
            )

        case .null:

            valueLabel.text =
                "null"

            valueLabel.textColor =
                .systemGray
        }
    }

    // MARK: - Action

    @objc
    private func toggleButtonClick() {

        toggleAction?()
    }
}



//import UIKit
//
//final class FHXJSONTreeCell: UITableViewCell {
//
//    static var identifier: String {
//        String(describing: self)
//    }
//
//    static func cell(
//        with tableView: UITableView
//    ) -> FHXJSONTreeCell {
//
//        let cell =
//            tableView.dequeueReusableCell(
//                withIdentifier: identifier
//            ) as? FHXJSONTreeCell
//
//        return cell
//            ?? FHXJSONTreeCell(
//                style: .default,
//                reuseIdentifier: identifier
//            )
//    }
//
//    // MARK: - UI
//
//    private lazy var toggleButton: UIButton = {
//
//        let button = UIButton()
//
//        button.layer.cornerRadius = 4
//        button.clipsToBounds = true
//
//        return button
//    }()
//
//    private lazy var keyLabel: UILabel = {
//
//        let label = UILabel()
//
//        label.font =
//            UIFont.monospacedSystemFont(
//                ofSize: 13,
//                weight: .regular
//            )
//
//        label.numberOfLines = 1
//
//        label.lineBreakMode =
//            .byTruncatingTail
//
//        label.textColor = UIColor(
//            red: 154.0 / 255.0,
//            green: 60.0 / 255.0,
//            blue: 153.0 / 255.0,
//            alpha: 1.0
//        )
//
//        return label
//    }()
//
//    private lazy var valueLabel: UILabel = {
//
//        let label = UILabel()
//
//        label.font =
//            UIFont.monospacedSystemFont(
//                ofSize: 13,
//                weight: .regular
//            )
//
//        label.numberOfLines = 1
//
//        label.lineBreakMode =
//            .byTruncatingTail
//
//        return label
//    }()
//
//    // MARK: - Constraint
//
//    private var toggleLeadingConstraint:
//        NSLayoutConstraint?
//
//    private var keyLeadingConstraint:
//        NSLayoutConstraint?
//
//    private var valueLeadingConstraint:
//        NSLayoutConstraint?
//
//    // MARK: - Property
//
//    private var toggleAction:
//        (() -> Void)?
//
//    // MARK: - Init
//
//    override init(
//        style: UITableViewCell.CellStyle,
//        reuseIdentifier: String?
//    ) {
//
//        super.init(
//            style: style,
//            reuseIdentifier: reuseIdentifier
//        )
//
//        selectionStyle = .none
//
//        buildUI()
//    }
//
//    required init?(
//        coder aDecoder: NSCoder
//    ) {
//
//        fatalError(
//            "init(coder:) has not been implemented"
//        )
//    }
//
//    override func prepareForReuse() {
//
//        super.prepareForReuse()
//
//        toggleAction = nil
//
//        keyLabel.text = nil
//
//        valueLabel.text = nil
//
//        valueLabel.textColor = .label
//
//        toggleButton.isHidden = false
//
//        toggleButton.setImage(
//            nil,
//            for: .normal
//        )
//
//        toggleLeadingConstraint?.constant = 5
//
//        keyLeadingConstraint?.constant = 0
//
//        valueLeadingConstraint?.constant = 4
//    }
//
//    // MARK: - UI
//
//    private func buildUI() {
//
//        contentView.addSubview(
//            toggleButton
//        )
//
//        contentView.addSubview(
//            keyLabel
//        )
//
//        contentView.addSubview(
//            valueLabel
//        )
//
//        toggleButton.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        keyLabel.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        valueLabel.translatesAutoresizingMaskIntoConstraints =
//            false
//
//        toggleLeadingConstraint =
//            toggleButton.leadingAnchor.constraint(
//                equalTo: contentView.leadingAnchor,
//                constant: 5
//            )
//
//        keyLeadingConstraint =
//            keyLabel.leadingAnchor.constraint(
//                equalTo: toggleButton.trailingAnchor
//            )
//
//        valueLeadingConstraint =
//            valueLabel.leadingAnchor.constraint(
//                equalTo: keyLabel.trailingAnchor,
//                constant: 4
//            )
//
//        guard
//            let toggleLeadingConstraint,
//            let keyLeadingConstraint,
//            let valueLeadingConstraint
//        else {
//            return
//        }
//
//        NSLayoutConstraint.activate([
//
//            toggleLeadingConstraint,
//
//            toggleButton.centerYAnchor.constraint(
//                equalTo: contentView.centerYAnchor
//            ),
//
//            toggleButton.widthAnchor.constraint(
//                equalToConstant: 24
//            ),
//
//            toggleButton.heightAnchor.constraint(
//                equalToConstant: 24
//            ),
//
//            keyLeadingConstraint,
//
//            keyLabel.centerYAnchor.constraint(
//                equalTo: contentView.centerYAnchor
//            ),
//
//            keyLabel.widthAnchor.constraint(
//                greaterThanOrEqualToConstant: 20
//            ),
//
//            valueLeadingConstraint,
//
//            valueLabel.trailingAnchor.constraint(
//                lessThanOrEqualTo: contentView.trailingAnchor,
//                constant: -10
//            ),
//
//            valueLabel.centerYAnchor.constraint(
//                equalTo: contentView.centerYAnchor
//            )
//        ])
//
//        keyLabel.setContentHuggingPriority(
//            .defaultLow,
//            for: .horizontal
//        )
//
//        keyLabel.setContentCompressionResistancePriority(
//            .defaultHigh,
//            for: .horizontal
//        )
//
//        valueLabel.setContentHuggingPriority(
//            .defaultLow,
//            for: .horizontal
//        )
//
//        valueLabel.setContentCompressionResistancePriority(
//            .defaultLow,
//            for: .horizontal
//        )
//
//        toggleButton.addTarget(
//            self,
//            action: #selector(
//                toggleButtonClick
//            ),
//            for: .touchUpInside
//        )
//    }
//
//    // MARK: - Config
//
//    func setNode(
//        _ node: FHXJSONNode,
//        toggleAction: @escaping () -> Void
//    ) {
//
//        self.toggleAction =
//            toggleAction
//
//        let indentation =
//            CGFloat(node.depth * 18)
//
//        /*
//         基础左边距 5pt
//         每增加一级 JSON 层级增加 18pt
//
//         第 0 层：5pt
//         第 1 层：23pt
//         第 2 层：41pt
//         第 3 层：59pt
//         */
//
//        toggleLeadingConstraint?.constant =
//            5 + indentation
//
//        keyLeadingConstraint?.constant =
//            0
//
//        valueLeadingConstraint?.constant =
//            4
//
//        if node.isContainer {
//
//            toggleButton.isHidden =
//                false
//
//            let frameworkBundle =
//                Bundle(
//                    for: FHXJSONTreeCell.self
//                )
//
//            if
//                let bundleURL =
//                    frameworkBundle.url(
//                        forResource: "file",
//                        withExtension: "bundle"
//                    ),
//                let sdkBundle =
//                    Bundle(
//                        url: bundleURL
//                    )
//            {
//
//                let addImage =
//                    UIImage(
//                        named: "add",
//                        in: sdkBundle,
//                        compatibleWith: nil
//                    )
//
//                let reduceImage =
//                    UIImage(
//                        named: "reduce",
//                        in: sdkBundle,
//                        compatibleWith: nil
//                    )
//
//                toggleButton.setImage(
//                    node.isExpanded
//                        ? reduceImage
//                        : addImage,
//                    for: .normal
//                )
//            }
//
//        } else {
//
//            toggleButton.isHidden =
//                true
//
//            toggleButton.setImage(
//                nil,
//                for: .normal
//            )
//        }
//
//        if node.key == "root" {
//
//            keyLabel.text = ""
//
//        } else if node.key.hasPrefix("[") {
//
//            keyLabel.text =
//                node.key
//
//        } else {
//
//            keyLabel.text =
//                "\"\(node.key)\":"
//        }
//
//        configureValue(
//            node.value,
//            isExpanded: node.isExpanded
//        )
//    }
//
//    // MARK: - Value
//
//    private func configureValue(
//        _ value: FHXJSONValue,
//        isExpanded: Bool
//    ) {
//
//        switch value {
//
//        case .dictionary:
//
//            /*
//             展开：
//             {
//             
//             折叠：
//             {...}
//             */
//
//            valueLabel.text =
//                isExpanded
//                    ? "{"
//                    : "{...}"
//
//            valueLabel.textColor =
//                .label
//
//        case .array:
//
//            /*
//             展开：
//             [
//             
//             折叠：
//             [...]
//             */
//
//            valueLabel.text =
//                isExpanded
//                    ? "["
//                    : "[...]"
//
//            valueLabel.textColor =
//                .label
//
//        case .string(let value):
//
//            valueLabel.text =
//                "\"\(value)\""
//
//            valueLabel.textColor = UIColor(
//                red: 0.0 / 255.0,
//                green: 144.0 / 255.0,
//                blue: 109.0 / 255.0,
//                alpha: 1.0
//            )
//
//        case .integer(let value):
//
//            valueLabel.text =
//                "\(value)"
//
//            valueLabel.textColor = UIColor(
//                red: 61.0 / 255.0,
//                green: 174.0 / 255.0,
//                blue: 227.0 / 255.0,
//                alpha: 1.0
//            )
//
//        case .double(let value):
//
//            valueLabel.text =
//                "\(value)"
//
//            valueLabel.textColor = UIColor(
//                red: 61.0 / 255.0,
//                green: 174.0 / 255.0,
//                blue: 227.0 / 255.0,
//                alpha: 1.0
//            )
//
//        case .bool(let value):
//
//            valueLabel.text =
//                value
//                    ? "true"
//                    : "false"
//
//            valueLabel.textColor = UIColor(
//                red: 247.0 / 255.0,
//                green: 144.0 / 255.0,
//                blue: 142.0 / 255.0,
//                alpha: 1.0
//            )
//
//        case .null:
//
//            valueLabel.text =
//                "null"
//
//            valueLabel.textColor =
//                .systemGray
//        }
//    }
//
//    // MARK: - Action
//
//    @objc
//    private func toggleButtonClick() {
//
//        toggleAction?()
//    }
//}

