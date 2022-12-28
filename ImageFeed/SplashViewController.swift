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
    private lazy var tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    private lazy var oAuth2Service: OAuth2ServiceProtocol = OAuth2Service()

    private var window: UIWindow {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration: unable to get window from UIApplication")
        }
        return window
    }

    private enum NetworkError: Error {
        case codeError
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

    private func getUserProfile(_ callback: @escaping (Result<UserProfile, Error>) -> Void) {
        guard isUserAuthorized else { return }
        let request = makeURLRequest()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                print("ERROR:", error)
                callback(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
               response.statusCode != 200 {
                print("HTTP ERROR:", response.statusCode)
                callback(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonResponse = try decoder.decode(UserProfile.self, from: data)
                callback(.success(jsonResponse))
            } catch {
                print("DECODING ERROR:", error)
                callback(.failure(error))
            }
        }
        task.resume()
        return
    }

    private func makeURLRequest() -> URLRequest {
        let baseURL = defaultBaseURL
        let profileURL = baseURL.appendingPathComponent("me")
        var request = URLRequest(url: profileURL)
        request.httpMethod = "GET"
        request.addValue("Authorization: Bearer \(tokenStorage.token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func selectUserFlow() {
        if isUserAuthorized {
            UIBlockingProgressHUD.show()
            switchToTabBarController()
            UIBlockingProgressHUD.dismiss()
        } else {
            switchToAuthViewController()
        }
    }

    private func switchToTabBarController() {
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            preconditionFailure("Unable to get TabBarController from Storyboard")
        }
        guard let profileViewController = tabBarController.viewControllers?[1] as? ProfileViewController else {
            preconditionFailure("Unable to get ProfileViewController from TabBarController")
        }
        getUserProfile { result in
            DispatchQueue.main.async { [weak self] in
                switch result {
                case .success(let userProfile):
                    let fullName = userProfile.firstName + " " + userProfile.lastName
                    profileViewController.nameLabel.text = fullName
                    profileViewController.nicknameLabel.text = userProfile.username
                case .failure(let error):
                    print("Unable to get user profile. Error: \(error). Try to authorize again")
                    self?.switchToAuthViewController()
                }
            }
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
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            self?.fetchAuthToken(usingCode: code)
        }
    }

    private func fetchAuthToken(usingCode code: String) {
        oAuth2Service.fetchAuthToken(code: code) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let accessToken):
                    self?.tokenStorage.setTokenValue(newValue: accessToken)
                    self?.isUserAuthorized = true
                    self?.switchToTabBarController()
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    print("ERROR (unable to get access token):", error)
                    self?.switchToAuthViewController()
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
}
