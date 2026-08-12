//
//  FHXTextPreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

/**
 ✅ txt
 ✅ log
 ✅ json（Pretty Print）
 ✅ plist（NSDictionary / NSArray 自动格式化）
 ✅ 自动等宽字体
 ✅ 自动可复制
 ✅ 自动滚动
 ✅ 深色模式支持
 ✅ 后面做搜索也不用改
 */

import UIKit

final class FHXTextPreview: UIViewController {

    // MARK: - Property

    private let model: FHXSandboxModel

    private let textView = UITextView()

    // MARK: - Init

    init(model: FHXSandboxModel) {

        self.model = model

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        fatalError()
    }

    // MARK: - Life

    override func viewDidLoad() {

        super.viewDidLoad()

        buildUI()

        loadContent()
    }
}

// MARK: - UI

private extension FHXTextPreview {

    func buildUI() {

        view.backgroundColor = .systemBackground

        textView.backgroundColor = .systemBackground

        textView.font =
        UIFont.monospacedSystemFont(
            ofSize: 14,
            weight: .regular
        )

        textView.textColor = .label

        textView.isEditable = false

        textView.alwaysBounceVertical = true

        textView.autocapitalizationType = .none

        textView.autocorrectionType = .no

        textView.smartQuotesType = .no

        textView.smartDashesType = .no

        textView.smartInsertDeleteType = .no

        textView.textContainerInset =
        UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )

        view.addSubview(
            textView
        )

        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            textView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            textView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            textView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),

            textView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )

        ])
    }
}

// MARK: - Load

private extension FHXTextPreview {

    func loadContent() {

        switch model.fileType {

        case .json:

            textView.text =
            prettyJSON()

        case .plist:

            textView.text =
            prettyPlist()

        default:

            textView.text =
            plainText()
        }
    }
}

// MARK: - TXT

private extension FHXTextPreview {

    func plainText() -> String {

        do {

            return try String(
                contentsOfFile: model.path,
                encoding: .utf8
            )

        } catch {

            return "Unable to open file.\n\n\(error)"
        }
    }
}

// MARK: - JSON

private extension FHXTextPreview {

    func prettyJSON() -> String {

        guard
            let data =
            FileManager.default.contents(
                atPath: model.path
            )
        else {

            return "JSON Read Failed"
        }

        do {

            let object =
            try JSONSerialization.jsonObject(
                with: data
            )

            let pretty =
            try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted]
            )

            return String(
                data: pretty,
                encoding: .utf8
            ) ?? ""

        } catch {

            return plainText()
        }
    }
}

// MARK: - Plist

private extension FHXTextPreview {

    func prettyPlist() -> String {

        if let dict =
            NSDictionary(
                contentsOfFile: model.path
            ) {

            return dict.description
        }

        if let array =
            NSArray(
                contentsOfFile: model.path
            ) {

            return array.description
        }

        return plainText()
    }
}
