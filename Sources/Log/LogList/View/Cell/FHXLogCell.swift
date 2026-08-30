import UIKit

class FHXLogCell: UITableViewCell {

    static let identifier = "FHXLogCellID"

    /// 点击展开回调
    var expandBlock: (() -> Void)?

    // MARK: - UI

    private lazy var line: UIView = {
        let line = UIView()

        line.backgroundColor = UIColor(
            red: 229.0 / 255.0,
            green: 229.0 / 255.0,
            blue: 229.0 / 255.0,
            alpha: 1.0
        )

        return line
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

        return label
    }()

    lazy var timeLabel: UILabel = {
        let label = UILabel()

        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)

        return label
    }()

    lazy var contentLabel: UILabel = {
        let label = UILabel()

        label.numberOfLines = 5
        label.lineBreakMode = .byTruncatingTail

        return label
    }()

    lazy var moreLabel: UILabel = {
        let label = UILabel()

        label.text = "......"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left

        return label
    }()

    lazy var expandButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("展开", for: .normal)

        button.setTitleColor(
            UIColor(
                red: 18.0 / 255.0,
                green: 150.0 / 255.0,
                blue: 219.0 / 255.0,
                alpha: 1.0
            ),
            for: .normal
        )

        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)

        button.layer.cornerRadius = 4
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(
            red: 18.0 / 255.0,
            green: 150.0 / 255.0,
            blue: 219.0 / 255.0,
            alpha: 1.0
        ).cgColor

        button.clipsToBounds = true

        button.addTarget(
            self,
            action: #selector(expandButtonClick),
            for: .touchUpInside
        )

        return button
    }()

    // MARK: - Init

    static func cell(
        with tableview: UITableView
    ) -> FHXLogCell {

        var cell = tableview.dequeueReusableCell(
            withIdentifier: identifier
        ) as? FHXLogCell

        if cell == nil {
            cell = FHXLogCell(
                style: .default,
                reuseIdentifier: identifier
            )
        }

        return cell!
    }

    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )

        buildUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI

    private func buildUI() {

        selectionStyle = .none
        backgroundColor = .white

        contentView.addSubview(line)
        contentView.addSubview(levelLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(methodNameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(moreLabel)
        contentView.addSubview(expandButton)

        line.translatesAutoresizingMaskIntoConstraints = false
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        methodNameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        moreLabel.translatesAutoresizingMaskIntoConstraints = false
        expandButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([

            // MARK: - line

            line.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor
            ),

            line.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor
            ),

            line.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor
            ),

            line.heightAnchor.constraint(
                equalToConstant: 1
            ),

            // MARK: - levelLabel

            levelLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 10
            ),

            levelLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
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
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            // MARK: - methodNameLabel

            methodNameLabel.topAnchor.constraint(
                equalTo: levelLabel.bottomAnchor,
                constant: 5
            ),

            methodNameLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            methodNameLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            // MARK: - contentLabel

            contentLabel.topAnchor.constraint(
                equalTo: methodNameLabel.bottomAnchor,
                constant: 5
            ),

            contentLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            contentLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            // MARK: - moreLabel

            moreLabel.topAnchor.constraint(
                equalTo: contentLabel.bottomAnchor,
                constant: 5
            ),

            moreLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 10
            ),

            moreLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -10
            ),

            // MARK: - expandButton

            expandButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -10
            ),

            expandButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -10
            ),

            expandButton.widthAnchor.constraint(
                equalToConstant: 50
            ),

            expandButton.heightAnchor.constraint(
                equalToConstant: 30
            )
        ])

        // 默认隐藏
        moreLabel.isHidden = true
        expandButton.isHidden = true
    }

    // MARK: - Expand

    func showExpandButton(_ show: Bool) {

        moreLabel.isHidden = !show
        expandButton.isHidden = !show
    }

    @objc
    private func expandButtonClick() {
        expandBlock?()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        moreLabel.isHidden = true
        expandButton.isHidden = true

        expandBlock = nil
    }
}
