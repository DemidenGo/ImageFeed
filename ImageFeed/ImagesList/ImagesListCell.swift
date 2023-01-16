//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 08.11.2022.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {

    weak var delegate: ImagesListCellDelegate?

    private lazy var likeActiveImage = UIImage(named: "LikeActive")
    private lazy var likeNoActiveImage = UIImage(named: "LikeNoActive")

    private lazy var backgroundCellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypBlack
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()

    private lazy var photoImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(
            size: CGSize(width: UIScreen.main.bounds.width - 32,
                         height: thumbImagePlaceholderSize.height)
        )
        view.layer.addSublayer(gradient)
        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypWhite
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(likeButtonAction), for: .touchUpInside)
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
        contentView.backgroundColor = .ypBlack
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // Отменяем загрузку, чтобы избежать багов при переиспользовании ячеек
        photoImageView.kf.cancelDownloadTask()
        // Сбрасываем предыдущий стейт ячейки
        photoImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(likeNoActiveImage, for: .normal)
        // Накладываем анимированный градиент
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(
            size: CGSize(width: UIScreen.main.bounds.width - 32,
                         height: thumbImagePlaceholderSize.height)
        )
        photoImageView.layer.addSublayer(gradient)
    }

    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(isLiked ? likeActiveImage : likeNoActiveImage, for: .normal)
    }

    func configure(with viewModel: CellViewModel, _ completion: @escaping  () -> Void) {
        photoImageView.kf.setImage(with: viewModel.thumbImageURL,
                                   placeholder: thumbImagePlaceholder) { [weak self] _ in
            self?.removeGradientLayer()
            completion()
        }
        setIsLiked(viewModel.isLiked)
        dateLabel.text = viewModel.createdAt
    }

    func removeGradientLayer() {
        photoImageView.layer.sublayers?.removeAll()
    }

    @objc private func likeButtonAction() {
        delegate?.imagesListCellDidTapLike(self)
    }

    private func setupConstraints() {
        contentView.addSubview(backgroundCellView)
        [photoImageView, gradientView, dateLabel, likeButton].forEach { backgroundCellView.addSubview($0) }
        NSLayoutConstraint.activate([
            backgroundCellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            backgroundCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            backgroundCellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            backgroundCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            photoImageView.topAnchor.constraint(equalTo: backgroundCellView.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: backgroundCellView.leadingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: backgroundCellView.bottomAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: backgroundCellView.trailingAnchor),

            dateLabel.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor, constant: -8),

            likeButton.heightAnchor.constraint(equalToConstant: 42),
            likeButton.widthAnchor.constraint(equalToConstant: 42),
            likeButton.topAnchor.constraint(equalTo: photoImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor),

            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: photoImageView.bottomAnchor),
            gradientView.trailingAnchor.constraint(equalTo: photoImageView.trailingAnchor)
        ])
    }
}
