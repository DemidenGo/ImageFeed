//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 29.11.2022.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {

    weak var delegate: WebViewViewControllerDelegate?

    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

    private lazy var unsplashAuthorizeURLComponents: URLComponents = {
        guard let components = URLComponents(string: unsplashAuthorizeURLString) else {
            preconditionFailure("Unable to construct unsplashAuthorizeURLComponents")
        }
        var unsplashURLComponents = components
        unsplashURLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: accessKey),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: accessScope)
        ]
        return unsplashURLComponents
    }()

    private lazy var unsplashAuthorizeURL: URL = {
        guard let url = unsplashAuthorizeURLComponents.url else {
            preconditionFailure("Unable to construct unsplashAuthorizeURL")
        }
        return url
    }()

    private lazy var urlRequest = URLRequest(url: unsplashAuthorizeURL)

    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypWhite
        return view
    }()

    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "BackwardBlack"), for: .normal)
        button.addTarget(self, action: #selector(backwardButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.progressTintColor = .ypBlack
        return view
    }()

    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configWebView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = (1 - progressView.progress) <= 0.0001
    }

    @objc private func backwardButtonAction() {
        delegate?.webViewViewControllerDidCancel(self)
    }

    private func configWebView() {
        webView.load(urlRequest)
        webView.navigationDelegate = self
    }

    private func layout() {
        [webView, backwardButton, progressView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),

            progressView.topAnchor.constraint(equalTo: backwardButton.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

//MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
