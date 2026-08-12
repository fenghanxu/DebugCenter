//
//  FHXGIFPreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

import UIKit
import ImageIO
import MobileCoreServices

final class FHXGIFPreview: UIViewController {

    // MARK: - Property

    private let model: FHXSandboxModel

    private let imageView = UIImageView()

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

        view.backgroundColor = .black

        imageView.frame = view.bounds

        imageView.autoresizingMask = [

            .flexibleWidth,

            .flexibleHeight
        ]

        imageView.contentMode = .scaleAspectFit

        view.addSubview(imageView)

        loadGIF()
    }
}

private extension FHXGIFPreview {

    func loadGIF() {

        guard

            let data = try? Data(
                contentsOf: URL(fileURLWithPath: model.path)
            ),

            let source =
            CGImageSourceCreateWithData(
                data as CFData,
                nil
            )

        else {

            return
        }

        var images: [UIImage] = []

        var duration: TimeInterval = 0

        let count =
        CGImageSourceGetCount(source)

        for index in 0..<count {

            guard

                let cgImage =
                CGImageSourceCreateImageAtIndex(
                    source,
                    index,
                    nil
                )

            else {

                continue
            }

            images.append(

                UIImage(
                    cgImage: cgImage
                )
            )

            duration += frameDuration(
                source: source,
                index: index
            )
        }

        if duration == 0 {

            duration = Double(count) * 0.1
        }

        imageView.animationImages = images

        imageView.animationDuration = duration

        imageView.animationRepeatCount = 0

        imageView.startAnimating()
    }
}

private extension FHXGIFPreview {

    func frameDuration(
        source: CGImageSource,
        index: Int
    ) -> TimeInterval {

        guard

            let properties =
            CGImageSourceCopyPropertiesAtIndex(
                source,
                index,
                nil
            ) as? [CFString: Any],

            let gif =
            properties[kCGImagePropertyGIFDictionary]
            as? [CFString: Any]

        else {

            return 0.1
        }

        if let delay =
            gif[kCGImagePropertyGIFUnclampedDelayTime]
            as? Double,
           delay > 0 {

            return delay
        }

        if let delay =
            gif[kCGImagePropertyGIFDelayTime]
            as? Double,
           delay > 0 {

            return delay
        }

        return 0.1
    }
}
