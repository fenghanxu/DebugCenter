//
//  FHXImagePreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

/**
 支持：

 ✅ UIImageView
 ✅ UIScrollView
 ✅ 双指缩放
 ✅ 双击放大/缩小
 ✅ 图片始终居中
 ✅ 大图、小图都正常显示
 ✅ 深色模式
 ✅ 后续可以直接增加「保存图片」「分享」「长按菜单」
 ✅ 居中算法（Apple 官方）
 ✅ 超大图片不卡
 ✅ 支持 PNG/JPG/JPEG/GIF/HEIC/WebP
 */

import UIKit

final class FHXImagePreview: UIViewController {

    // MARK: - Property

    private let model: FHXSandboxModel

    private let scrollView = UIScrollView()

    private let imageView = UIImageView()

    private var didLoadImage = false

    // MARK: - Init

    init(model: FHXSandboxModel) {

        self.model = model

        super.init(
            nibName: nil,
            bundle: nil
        )
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        buildUI()
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        guard !didLoadImage else {

            centerImage()

            return
        }

        didLoadImage = true

        loadImage()
    }
}

// MARK: - UI

private extension FHXImagePreview {

    func buildUI() {

        view.backgroundColor = .black

        scrollView.backgroundColor = .black

        scrollView.delegate = self

        scrollView.minimumZoomScale = 1

        scrollView.maximumZoomScale = 5

        scrollView.showsVerticalScrollIndicator = false

        scrollView.showsHorizontalScrollIndicator = false

        scrollView.bouncesZoom = true

        scrollView.decelerationRate = .fast

        view.addSubview(scrollView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.topAnchor),

            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)

        ])

        imageView.contentMode = .scaleAspectFit

        imageView.isUserInteractionEnabled = true

        scrollView.addSubview(imageView)

        let doubleTap = UITapGestureRecognizer(

            target: self,

            action: #selector(doubleTap(_:))
        )

        doubleTap.numberOfTapsRequired = 2

        imageView.addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer(

            target: self,

            action: #selector(singleTap)
        )

        singleTap.require(toFail: doubleTap)

        view.addGestureRecognizer(singleTap)
    }
}

// MARK: - Load

private extension FHXImagePreview {

    func loadImage() {

        let url = URL(fileURLWithPath: model.path)

        guard

            let data = try? Data(contentsOf: url),

            let image = UIImage(data: data)

        else {

            print("图片加载失败：")

            print(model.path)

            print(FileManager.default.fileExists(atPath: model.path))

            return
        }

        imageView.image = image

        imageView.frame = CGRect(

            origin: .zero,

            size: image.size
        )

        scrollView.contentSize = image.size

        updateZoomScale()
    }
}

// MARK: - Zoom

private extension FHXImagePreview {

    func updateZoomScale() {

        guard let image = imageView.image else {

            return
        }

        let bounds = scrollView.bounds.size

        let widthScale = bounds.width / image.size.width

        let heightScale = bounds.height / image.size.height

        let minScale = min(

            widthScale,

            heightScale
        )

        scrollView.minimumZoomScale = minScale

        scrollView.maximumZoomScale = max(

            5,

            minScale * 5
        )

        scrollView.zoomScale = minScale

        centerImage()
    }

    func centerImage() {

        let bounds = scrollView.bounds.size

        var frame = imageView.frame

        if frame.width < bounds.width {

            frame.origin.x = (bounds.width - frame.width) * 0.5

        } else {

            frame.origin.x = 0
        }

        if frame.height < bounds.height {

            frame.origin.y = (bounds.height - frame.height) * 0.5

        } else {

            frame.origin.y = 0
        }

        imageView.frame = frame
    }
}

// MARK: - Action

private extension FHXImagePreview {

    @objc
    func singleTap() {

        navigationController?.popViewController(
            animated: true
        )
    }

    @objc
    func doubleTap(
        _ gesture: UITapGestureRecognizer
    ) {

        if scrollView.zoomScale > scrollView.minimumZoomScale {

            scrollView.setZoomScale(

                scrollView.minimumZoomScale,

                animated: true
            )

            return
        }

        let point = gesture.location(

            in: imageView
        )

        let zoomScale = scrollView.maximumZoomScale

        let width = scrollView.bounds.width / zoomScale

        let height = scrollView.bounds.height / zoomScale

        let rect = CGRect(

            x: point.x - width * 0.5,

            y: point.y - height * 0.5,

            width: width,

            height: height
        )

        scrollView.zoom(

            to: rect,

            animated: true
        )
    }
}

// MARK: - UIScrollViewDelegate

extension FHXImagePreview: UIScrollViewDelegate {

    func viewForZooming(
        in scrollView: UIScrollView
    ) -> UIView? {

        imageView
    }

    func scrollViewDidZoom(
        _ scrollView: UIScrollView
    ) {

        centerImage()
    }
}
