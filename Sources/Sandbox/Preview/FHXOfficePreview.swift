//
//  FHXOfficePreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

import UIKit
import QuickLook

final class FHXOfficePreview: QLPreviewController {

    // MARK: - Property

    private let model: FHXSandboxModel

    // MARK: - Init

    init(model: FHXSandboxModel) {

        self.model = model

        super.init(nibName: nil, bundle: nil)

        dataSource = self
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        title = model.name

        view.backgroundColor = .systemBackground
    }
}

// MARK: - QLPreviewControllerDataSource

extension FHXOfficePreview: QLPreviewControllerDataSource {

    func numberOfPreviewItems(
        in controller: QLPreviewController
    ) -> Int {

        1
    }

    func previewController(
        _ controller: QLPreviewController,
        previewItemAt index: Int
    ) -> QLPreviewItem {

        URL(
            fileURLWithPath: model.path
        ) as NSURL
    }
}
