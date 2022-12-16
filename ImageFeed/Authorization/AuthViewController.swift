//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 29.11.2022.
//

import UIKit

final class AuthViewController: UIViewController {

    // держим сильную ссылку на SplashViewController, иначе он будет удалён из памяти
    var delegate: AuthViewControllerDelegate?

    private lazy var logoImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: "Logo_of_Unsplash")
        return view
    }()

    private lazy var enterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypWhite
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(UIColor.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Bold", size: 17)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(enterButtonTargetForTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(enterButtonTargetForTouchUp), for: .touchUpInside)
        button.addTarget(self, action: #selector(enterButtonTargetForTouchUp), for: .touchUpOutside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupConstraints()
    }

    @objc private func enterButtonTargetForTouchDown() {
        enterButton.backgroundColor = .ypWhiteAlpha50
    }

    @objc private func enterButtonTargetForTouchUp() {
        enterButton.backgroundColor = .ypWhite
        presentWebViewViewController()
    }

    func presentWebViewViewController() {
        let webViewViewController = WebViewViewController()
        webViewViewController.modalPresentationStyle = .fullScreen
        present(webViewViewController, animated: true)
        webViewViewController.delegate = self
    }

    private func setupConstraints() {
        [logoImageView, enterButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            enterButton.heightAnchor.constraint(equalToConstant: 48),
            enterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -90),
            enterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

//MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        delegate?.authViewControllerDelegate(self, didAuthenticateWithCode: code)
        vc.dismiss(animated: true)
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
