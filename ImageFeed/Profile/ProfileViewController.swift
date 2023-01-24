//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 17.11.2022.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol? { get set }
    func setProfileDetails(name: String, nickname: String, bio: String?)
    func setAvatar(url: URL)
    func removeGradientLayersFromProfileDetails()
}

final class ProfileViewController: UIViewController {

    var presenter: ProfilePresenterProtocol?
    private lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)
    private var profileImageServiceObserver: NSObjectProtocol?

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .ypBlack
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(size: CGSize(width: 70, height: 70))
        imageView.layer.addSublayer(gradient)
        return imageView
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "Exit"), for: .normal)
        button.tintColor = .ypRed
        button.addTarget(self, action: #selector(logoutButtonAction), for: .touchUpInside)
        return button
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
        label.textColor = .ypWhite
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(size: CGSize(width: 223, height: 20))
        label.layer.addSublayer(gradient)
        return label
    }()

    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        label.textColor = .ypGray
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(size: CGSize(width: 89, height: 18))
        label.layer.addSublayer(gradient)
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        label.textColor = .ypWhite
        let gradient = CAGradientLayer.makeGradientLayerWithAnimation(size: CGSize(width: 67, height: 18))
        label.layer.addSublayer(gradient)
        return label
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addProfileImageServiceObserver()
        setupConstraints()
        presenter?.didUpdateProfileDetails()
        presenter?.didUpdateAvatar()
    }

    @objc private func logoutButtonAction() {
        errorAlertPresenter.presentAlert(title: "Пока, пока!",
                                         message: "Уверены что хотите выйти?",
                                         buttonTitles: "Да", "Нет",
                                         buttonActions:
                                            { [weak self] in
                                                self?.presenter?.deleteCurrentAccessTokenAndCleanCash()
                                                self?.presenter?.switchToSplashViewController() }, {  })
    }

    private func addProfileImageServiceObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.presenter?.didUpdateAvatar()
                }
    }

    private func removeGradientLayerFromAvatar() {
        avatarImageView.layer.sublayers?.removeAll()
    }

    private func setupConstraints() {
        [avatarImageView, logoutButton, nameLabel, nicknameLabel, statusLabel].forEach { view.addSubview($0) }
        let inset: CGFloat = 8
        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4 * inset),
            avatarImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * inset),

            logoutButton.heightAnchor.constraint(equalToConstant: 3 * inset),
            logoutButton.widthAnchor.constraint(equalToConstant: 3 * inset),
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7 * inset),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * inset),

            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: inset),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * inset),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2 * inset),

            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: inset),
            nicknameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * inset),

            statusLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: inset),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2 * inset)
        ])
    }
}

// MARK: - ProfileViewControllerProtocol

extension ProfileViewController: ProfileViewControllerProtocol {

    func setProfileDetails(name: String, nickname: String, bio: String?) {
        nameLabel.text = name
        nicknameLabel.text = nickname
        statusLabel.text = bio
    }

    func setAvatar(url: URL) {
        ImageCache.default.clearCache()
        avatarImageView.kf.setImage(with: url, placeholder: avatarPlaceholder) { [weak self] result in
            switch result {
            case .success(let value):
                self?.removeGradientLayerFromAvatar()
                self?.avatarImageView.image = value.image
            case .failure(let error):
                print("ERROR update avatar: ", error.errorCode, " ", error.localizedDescription)
                self?.presenter?.didUpdateAvatar()
            }
        }
    }

    func removeGradientLayersFromProfileDetails() {
        [nameLabel, nicknameLabel, statusLabel].forEach { $0.layer.sublayers?.removeAll() }
    }
}
