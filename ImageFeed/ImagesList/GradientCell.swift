//
//  GradientCell.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 30.01.2023.
//

import UIKit

final class GradientCell: UITableViewCell {

    private var gradientSize: CGSize {
        CGSize(width: screenWidth - 32, height: thumbImagePlaceholderSize.height)
    }

    private lazy var placeholderImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.image = thumbImagePlaceholder
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        CAGradientLayer.makeGradientLayerWithAnimation(size: gradientSize)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .ypBlack
        placeholderImageView.layer.addSublayer(gradientLayer)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupConstraints() {
        contentView.addSubview(placeholderImageView)
        NSLayoutConstraint.activate([
            placeholderImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            placeholderImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            placeholderImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            placeholderImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
