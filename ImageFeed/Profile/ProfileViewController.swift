//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 17.11.2022.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    var delegate: ProfileViewControllerDelegate?

    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private lazy var profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .ypBlack
        imageView.image = UIImage(named: "avatar.png")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
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
        label.text = "Юрий Демиденко"
        label.font = UIFont(name: "YSDisplay-Bold", size: 23)
        label.textColor = .ypWhite
        return label
    }()

    lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@demidengo"
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        label.textColor = .ypGray
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, world!"
        label.font = UIFont(name: "YSDisplay-Regular", size: 13)
        label.textColor = .ypWhite
        return label
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        addProfileImageServiceObserver()
        setupConstraints()
        updateProfileDetails(from: profileService.profile)
        updateAvatar()
    }

    @objc private func logoutButtonAction() {
        delegate?.profileViewControllerDidLogout()
    }

    private func updateProfileDetails(from profile: Profile?) {
        guard let profile = profile else { preconditionFailure("Unable to get user profile") }
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
        statusLabel.text = profile.bio
    }

    private func addProfileImageServiceObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.updateAvatar()
                }
    }

    private func updateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        let cache = ImageCache.default
        cache.clearCache()
        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(with: url,
                                    placeholder: UIImage(named: "AvatarPlaceholder.png")) { [weak self] result in
            switch result {
            case .success(let value):
                self?.avatarImageView.image = value.image
            case .failure(let error):
                print("ERROR update avatar: ", error.errorCode, " ", error.localizedDescription)
                self?.updateAvatar()
            }
        }
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
