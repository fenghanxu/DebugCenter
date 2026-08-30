//
//  FHXDetailViewController.swift
//  DebugCenter
//
//  Created by imac on 2026/8/15.
//

import UIKit

class FHXDetailViewController: UIViewController {

    // MARK: - Property

    var model: FHXLogModel?

    // MARK: - UI

    private lazy var navigationView: FHXCurrentNavigationView = {

        let view = FHXCurrentNavigationView()

        view.delegate = self
        view.backgroundColor = .white

        return view
    }()

    private lazy var scrollView: UIScrollView = {

        let scrollView = UIScrollView()

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false

        return scrollView
    }()

    private lazy var container: UIView = {

        let view = UIView()

        view.backgroundColor = .white

        return view
    }()

    private lazy var levelLabel: UILabel = {

        let label = UILabel()

        label.text = "error"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .red
        label.textAlignment = .center

        label.layer.cornerRadius = 4.0
        label.clipsToBounds = true

        return label
    }()

    private lazy var methodNameLabel: UILabel = {

        let label = UILabel()

        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "URLSession"
        label.numberOfLines = 1

        return label
    }()

    private lazy var timeLabel: UILabel = {

        let label = UILabel()

        label.textColor = .black
        label.text = "2026-07-20 22:03:23"
        label.font = UIFont.systemFont(ofSize: 14)

        return label
    }()

    private lazy var contentLabel: UILabel = {

        let label = UILabel()

        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping

        return label
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {

        super.viewDidLoad()

        buildUI()

        if let model = model {
            setModel(model)
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(
            true,
            animated: animated
        )
    }

    override func viewWillDisappear(_ animated: Bool) {

        super.viewWillDisappear(animated)

        navigationController?.setNavigationBarHidden(
            false,
            animated: animated
        )
    }

    // MARK: - UI Setup

    private func buildUI() {

        view.backgroundColor = .white

        // 添加视图

        view.addSubview(navigationView)
        view.addSubview(scrollView)

        scrollView.addSubview(container)

        container.addSubview(levelLabel)
        container.addSubview(timeLabel)
        container.addSubview(methodNameLabel)
        container.addSubview(contentLabel)

        // 关闭 autoresizing mask

        navigationView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        methodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // MARK: - navigationView

            navigationView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            navigationView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),

            navigationView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            navigationView.heightAnchor.constraint(
                equalToConstant: safeAreaTopSDK + 44
            ),

            // MARK: - scrollView

            scrollView.topAnchor.constraint(
                equalTo: navigationView.bottomAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),

            // MARK: - container

            container.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),

            container.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),

            container.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),

            container.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            ),

            // 关键：container 宽度等于 ScrollView 可视区域宽度
            container.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),

            // MARK: - levelLabel

            levelLabel.topAnchor.constraint(
                equalTo: container.topAnchor,
                constant: 10
            ),

            levelLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 10
            ),

            levelLabel.widthAnchor.constraint(
                equalToConstant: 60
            ),

            levelLabel.heightAnchor.constraint(
                equalToConstant: 22
            ),

            // MARK: - timeLabel

            timeLabel.centerYAnchor.constraint(
                equalTo: levelLabel.centerYAnchor
            ),

            timeLabel.leadingAnchor.constraint(
                equalTo: levelLabel.trailingAnchor,
                constant: 10
            ),

            timeLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -10
            ),

            // MARK: - methodNameLabel

            methodNameLabel.topAnchor.constraint(
                equalTo: levelLabel.bottomAnchor,
                constant: 5
            ),

            methodNameLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 10
            ),

            methodNameLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -10
            ),

            methodNameLabel.heightAnchor.constraint(
                equalToConstant: 18
            ),

            // MARK: - contentLabel

            contentLabel.topAnchor.constraint(
                equalTo: methodNameLabel.bottomAnchor,
                constant: 5
            ),

            contentLabel.leadingAnchor.constraint(
                equalTo: container.leadingAnchor,
                constant: 10
            ),

            contentLabel.trailingAnchor.constraint(
                equalTo: container.trailingAnchor,
                constant: -10
            ),

            contentLabel.bottomAnchor.constraint(
                equalTo: container.bottomAnchor,
                constant: -10
            )
        ])
    }

    // MARK: - Model

    private func setModel(_ model: FHXLogModel) {

        levelLabel.text = "\(model.level)"
        timeLabel.text = model.timeString
        levelLabel.backgroundColor = model.level.color
        methodNameLabel.text = model.methodString

        contentLabel.attributedText = model.messageAttributed

        navigationView.setData(model.message)
    }
}

extension FHXDetailViewController: FHXCurrentNavigationViewDelegate {

    func fhxCurrentNavigationView(view: FHXCurrentNavigationView, buttonClick: UIButton) {
        dismiss(animated: true)
    }
}
