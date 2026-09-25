//
//  FHXSandboxPreviewController.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

/**
 Sandbox
 │
 ├── 文件浏览
 │      ✅
 │
 ├── 图片浏览
 │      ✅
 │
 ├── JSON
 │      ✅ Pretty Print
 │
 ├── TXT
 │      ✅
 │
 ├── LOG
 │      ✅
 │
 ├── Plist
 │      ✅
 │
 ├── PDF
 │      ✅
 │
 ├── Video
 │      ✅
 │
 └── Audio
        ✅
 */

import UIKit

final class FHXSandboxPreviewController: UIViewController {
    
    private lazy var navigationView: SandboxNavigationView = {
        let navigationView = SandboxNavigationView()
        return navigationView
    }()

    // MARK: - Property

    private let model: FHXSandboxModel

    // MARK: - Init

    init(
        model: FHXSandboxModel
    ) {

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

        view.backgroundColor = .systemBackground

        title = model.name

        loadPreview()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

// MARK: - Preview

private extension FHXSandboxPreviewController {

    func loadPreview() {

        switch model.fileType {

        case .image:
            show(FHXImagePreview(model: model))
        case .gif:
            show(FHXGIFPreview(model: model))
        case .json,
             .text,
             .plist:
            show(FHXTextPreview(model: model))
        case .pdf:
            show(FHXPDFPreview(model: model))
        case .video,
             .audio:
            show(FHXMediaPreview(model: model))
        case .word,
             .excel,
             .powerpoint:
            show(FHXOfficePreview(model: model))
        case .svg:
            show(FHXSVGPreview(model: model))
        case .tif:
            show(FHXTIFPreview(model: model))
        default:
            showInfo()
        }
    }

    func show(
        _ controller: UIViewController
    ) {
        
        view.addSubview(navigationView)
        navigationView.frame = CGRectMake(0, 0, screenWidthSDK, safeAreaTopSDK + 44)
        navigationView.title = model.name

        addChild(controller)

        view.addSubview(controller.view)
        controller.view.frame = CGRectMake(0, safeAreaTopSDK + 44, screenWidthSDK, screenHeightSDK - safeAreaTopSDK - 44)

        controller.view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        controller.didMove(
            toParent: self
        )
    }

    func showInfo() {

        let label = UILabel()

        label.textAlignment = .center

        label.numberOfLines = 0

        label.text = """

        暂不支持预览

        \(model.name)

        """

        label.frame = view.bounds

        label.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        view.addSubview(label)
    }

}
