//
//  FHXSVGPreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

import UIKit
import WebKit

final class FHXSVGPreview: UIViewController {


    // MARK: - Property


    private let model: FHXSandboxModel


    private let webView =
    WKWebView()


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


    required init?(
        coder: NSCoder
    ) {

        fatalError()
    }


    // MARK: - Life


    override func viewDidLoad() {

        super.viewDidLoad()


        buildUI()


        loadSVG()
    }
}

private extension FHXSVGPreview {


    func buildUI() {


        view.backgroundColor =
        .systemBackground


        webView.backgroundColor =
        .clear


        webView.isOpaque = false


        view.addSubview(
            webView
        )


        webView.translatesAutoresizingMaskIntoConstraints =
        false


        NSLayoutConstraint.activate([


            webView.leadingAnchor.constraint(
                equalTo:view.leadingAnchor
            ),


            webView.trailingAnchor.constraint(
                equalTo:view.trailingAnchor
            ),


            webView.topAnchor.constraint(
                equalTo:view.safeAreaLayoutGuide.topAnchor
            ),


            webView.bottomAnchor.constraint(
                equalTo:view.bottomAnchor
            )

        ])
    }
}

private extension FHXSVGPreview {


    func loadSVG() {


        let url =
        URL(
            fileURLWithPath:model.path
        )


        guard
            let data =
            try? Data(
                contentsOf:url
            )

        else {

            return
        }



        webView.load(
            data,
            mimeType:"image/svg+xml",
            characterEncodingName:"utf-8",
            baseURL:url.deletingLastPathComponent()
        )

    }
}

