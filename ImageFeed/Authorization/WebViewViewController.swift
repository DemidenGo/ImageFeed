//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 29.11.2022.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController {

    var presenter: WebViewPresenterProtocol?

    weak var delegate: WebViewViewControllerDelegate?

    private var estimatedProgressObservation: NSKeyValueObservation?

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
        view.backgroundColor = .ypWhite
        setupConstraints()
        configWebView()
        addWebViewLoadObserver()
    }

    @objc private func backwardButtonAction() {
        delegate?.webViewViewControllerDidCancel(self)
    }

    private func configWebView() {
        presenter?.viewDidLoad()
        webView.navigationDelegate = self
    }

    private func addWebViewLoadObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: []) { [weak self] _, _ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             }
    }

    private func setupConstraints() {
        [backwardButton, progressView, webView].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),

            progressView.topAnchor.constraint(equalTo: backwardButton.bottomAnchor, constant: 9),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

// MARK: - WebViewViewControllerProtocol

extension WebViewViewController: WebViewViewControllerProtocol {

    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}
