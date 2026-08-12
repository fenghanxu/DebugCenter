//
//  FHXDetailView.swift
//  SwiftDemol
//
//  Created by imac on 2026/7/14.
//

import UIKit

class FHXDetailView: UIView {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with model: FHXLogModel) {
        self.model = model
        
        let targetRect = CGRect(x: 0, y: 0, width: screenWidthSDK, height: screenHeightSDK)
        
        super.init(frame: targetRect)
        
        buildUI()
        setModel(model)
    }
    
    private lazy var navigationView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let frameworkBundle = Bundle(for: FHXDetailView.self)
        if let bundleURL = frameworkBundle.url(forResource: "file", withExtension: "bundle"),
        let sdkBundle = Bundle(url: bundleURL) {
            let image = UIImage(named: "cancel", in: sdkBundle, compatibleWith: nil)
            button.setImage(image, for: .normal)
        }
        button.addTarget(self, action: #selector(cancelButtonClick), for: .touchUpInside)
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: bounds.size.width, height: 70)
        scrollView.bounces = false
        return scrollView
    }()
    
    private lazy var container: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var levelLabel: UILabel = {
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
    
    lazy var methodNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.text = "URLSession"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.text = "2026-07-20 22:03:23"
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        label.text = "fenghanxu"
        return label
    }()
    
    private var model:FHXLogModel?
    
    static func showCurrentView(model: FHXLogModel, VCView: UIView) {
        let selfView = FHXDetailView(with: model)
        VCView.addSubview(selfView)
        selfView.showView()
    }
    
    // MARK: - UI Setup

    private func buildUI() {

        backgroundColor = .clear

        // 添加视图
        addSubview(navigationView)
        navigationView.addSubview(cancelButton)

        addSubview(scrollView)
        scrollView.addSubview(container)

        container.addSubview(levelLabel)
        container.addSubview(timeLabel)
        container.addSubview(methodNameLabel)
        container.addSubview(contentLabel)

        // 关闭 autoresizing mask
        navigationView.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        methodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        // container 使用 frame + scrollView contentSize
        // 所以这里不设置 Auto Layout 约束
        container.translatesAutoresizingMaskIntoConstraints = true

        NSLayoutConstraint.activate([

            // MARK: - navigationView

            navigationView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            navigationView.topAnchor.constraint(
                equalTo: topAnchor
            ),

            navigationView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            navigationView.heightAnchor.constraint(
                equalToConstant: safeAreaTopSDK + 44
            ),

            // MARK: - cancelButton

            cancelButton.leadingAnchor.constraint(
                equalTo: navigationView.leadingAnchor,
                constant: 15
            ),

            cancelButton.bottomAnchor.constraint(
                equalTo: navigationView.bottomAnchor,
                constant: -5
            ),

            cancelButton.widthAnchor.constraint(
                equalToConstant: 30
            ),

            cancelButton.heightAnchor.constraint(
                equalToConstant: 30
            ),

            // MARK: - scrollView

            scrollView.topAnchor.constraint(
                equalTo: navigationView.bottomAnchor
            ),

            scrollView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),

            scrollView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),

            scrollView.bottomAnchor.constraint(
                equalTo: bottomAnchor
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
                equalTo: container.bottomAnchor
            )
        ])

        // 初始 container frame
        container.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.size.width,
            height: 70
        )
    }
    
    private func setModel(_ model: FHXLogModel) {
        levelLabel.text = "\(model.level)"
        timeLabel.text = model.timeString
        levelLabel.backgroundColor = model.level.color
        methodNameLabel.text = model.methodString
        contentLabel.attributedText = model.messageAttributed
        
        let height = 60 + model.contentFullHeight
        scrollView.contentSize = CGSize(width: bounds.size.width, height: height)
        container.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: height)
    }
    
    private func showView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundColor = .black.withAlphaComponent(0.5)
        })
    }
    
    private func dismissView(){
        self.removeFromSuperview()
        backgroundColor = .clear
    }
    
    @objc func cancelButtonClick() {
        self.dismissView()
    }

}




