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
    private let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private lazy var authService: AuthServiceProtocol = OAuth2Service()
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared
    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private lazy var profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    private lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)

    private var window: UIWindow {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration: unable to get window from UIApplication")
        }
        return window
    }

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
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            preconditionFailure("Unable to get TabBarController from Storyboard")
        }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func switchToAuthViewController() {
        guard let navigationController = mainStoryboard.instantiateViewController(withIdentifier: "NavigationController") as? UINavigationController else {
            preconditionFailure("Unable to get NavigationController from Storyboard")
        }
        guard let authViewController = navigationController.viewControllers.first as? AuthViewController else {
            preconditionFailure("Unable to get AuthViewController from NavigationController")
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
