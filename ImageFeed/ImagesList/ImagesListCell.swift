//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 08.11.2022.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    private lazy var backgroundCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypBlack
        return view
    }()

    private lazy var image: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "0")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "9 ноября 2022"
        label.textColor = .ypWhite
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "LikeNoActive"), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()

    private lazy var gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        let gradient = CAGradientLayer()
        let gradientWidth = UIScreen.main.bounds.width - 32
        gradient.frame = CGRect(x: 0, y: 0, width: gradientWidth, height: 30)
        gradient.colors = [UIColor.gradientStart.cgColor, UIColor.gradientEnd.cgColor]
        view.layer.addSublayer(gradient)
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonAction() {
        if likeButton.image(for: .normal) == UIImage(named: "LikeNoActive") {
            likeButton.setImage(UIImage(named: "LikeActive"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "LikeNoActive"), for: .normal)
        }
    }

    private func layout() {
        contentView.addSubview(backgroundCellView)
        [image, gradientView, dateLabel, likeButton].forEach { backgroundCellView.addSubview($0) }
        NSLayoutConstraint.activate([
            backgroundCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            image.topAnchor.constraint(equalTo: backgroundCellView.topAnchor),
            image.leadingAnchor.constraint(equalTo: backgroundCellView.leadingAnchor, constant: 16),
            image.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor),
            image.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor, constant: -16),

            dateLabel.heightAnchor.constraint(equalToConstant: 18),
            dateLabel.widthAnchor.constraint(equalToConstant: 152),
            dateLabel.leadingAnchor.constraint(equalTo: image.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: image.bottomAnchor, constant: -8),

            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.topAnchor.constraint(equalTo: image.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: image.trailingAnchor),

            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: image.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: image.trailingAnchor)
        ])
    }
}
