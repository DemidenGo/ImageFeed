//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 06.12.2022.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    private var isUserAuthorized = false
    private lazy var authService: AuthServiceProtocol = OAuth2Service()
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared
    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private lazy var profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    private lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "launch_screen_logo")
        imageView.image = image
        return imageView
    }()

    //MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserAuthorization()
        selectUserFlow()
    }

    //MARK: - Private funcs

    private func setupConstraints() {
        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func checkUserAuthorization() {
        if tokenStorage.token != "" {
            isUserAuthorized = true
        }
    }

    private func selectUserFlow() {
        if isUserAuthorized {
            UIBlockingProgressHUD.show()
            fetchProfile(token: tokenStorage.token)
        } else {
            switchToAuthViewController()
        }
    }

    private func switchToTabBarController() {
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController,
              let imagesListViewController = tabBarController.viewControllers?[safe: 0] as? ImagesListViewController,
              let profileViewController = tabBarController.viewControllers?[safe: 1] as? ProfileViewController else {
            preconditionFailure("Unable to get tabBarController with viewControllers from Storyboard")
        }
        let imagesListPresenter = ImagesListPresenter()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func switchToAuthViewController() {
        guard let navigationController = mainStoryboard.instantiateViewController(
            withIdentifier: "NavigationController") as? UINavigationController,
              let authViewController = navigationController.viewControllers[safe: 0] as? AuthViewController else {
            preconditionFailure("Unable to get NavigationController or AuthViewController from Storyboard")
        }
        authViewController.delegate = self
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}

//MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {

    func authViewControllerDelegate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        dismiss(animated: true) { [weak self] in
            UIBlockingProgressHUD.show()
            self?.fetchAuthToken(usingCode: code)
        }
    }

    private func fetchAuthToken(usingCode code: String) {
        authService.fetchAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    self?.tokenStorage.setTokenValue(newValue: accessToken)
                    self?.isUserAuthorized = true
                    self?.fetchProfile(token: accessToken)
                case .failure(let error):
                    print("ERROR (unable to get access token):", error)
                    UIBlockingProgressHUD.dismiss()
                    self?.errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                                           message: "Не удалось войти в систему",
                                                           buttonTitles: "Ок") {
                        self?.switchToAuthViewController()
                    }
                }
            }
        }
    }

    private func fetchProfile(token: String) {
        profileService.fetchProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    let username = profile.username
                    self?.fetchProfileImageURL(for: username)
                    UIBlockingProgressHUD.dismiss()
                    self?.switchToTabBarController()
                case .failure(let error):
                    print("Unable to get user profile. Error: \(error). Try to authorize again")
                    UIBlockingProgressHUD.dismiss()
                    self?.errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                                           message: "Не удалось войти в систему",
                                                           buttonTitles: "Ок") {
                        self?.switchToAuthViewController()
                    }
                }
            }
        }
    }

    private func fetchProfileImageURL(for username: String) {
        profileImageService.fetchProfileImageURL(for: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileImageURL):
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self?.profileImageService,
                            userInfo: ["URL": profileImageURL])
                case .failure(let error):
                    print("Unable to get user image URL. Error: \(error). Try to authorize again")
                    self?.errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                                           message: "Не удалось войти в систему",
                                                           buttonTitles: "Ок") {
                        self?.switchToAuthViewController()
                    }
                }
            }
        }
    }
}
