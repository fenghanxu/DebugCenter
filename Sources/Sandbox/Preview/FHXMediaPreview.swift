//
//  FHXMediaPreview.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/25.
//

/**
 支持：

 ✅ mp4
 ✅ mov
 ✅ mp3
 ✅ aac
 ✅ wav
 ✅ 自动播放
 ✅ AVPlayerViewController
 ✅ 横屏全屏
 ✅ 系统播放控制
 ✅ 后台播放（App 开启 Background Audio 后即可）
 */

import UIKit
import AVKit
import AVFoundation

final class FHXMediaPreview: UIViewController {

    // MARK: - Property

    private let model: FHXSandboxModel

    private var player: AVPlayer?

    private var playerController: AVPlayerViewController?

    // MARK: - Init

    init(model: FHXSandboxModel) {

        self.model = model

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        title = model.name

        view.backgroundColor = .black

        setupAudioSession()

        setupPlayer()
    }

    override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)

        player?.pause()
    }
}

// MARK: - Private

private extension FHXMediaPreview {

    func setupAudioSession() {

        do {

            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .moviePlayback,
                options: [.allowAirPlay]
            )

            try AVAudioSession.sharedInstance().setActive(true)

        } catch {

            print("AVAudioSession Error:", error)
        }
    }

    func setupPlayer() {

        let url = URL(fileURLWithPath: model.path)

        let player = AVPlayer(url: url)

        self.player = player

        let controller = AVPlayerViewController()

        controller.player = player
        controller.showsPlaybackControls = true
        controller.entersFullScreenWhenPlaybackBegins = true
        controller.exitsFullScreenWhenPlaybackEnds = false

        addChild(controller)

        view.addSubview(controller.view)

        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        controller.didMove(toParent: self)

        playerController = controller

        player.play()
    }
}
