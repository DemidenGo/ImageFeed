//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 19.01.2023.
//

import UIKit

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {

    var authHelper: AuthHelperProtocol
    weak var view: WebViewViewControllerProtocol?

    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }

    func viewDidLoad() {
        let request = authHelper.authRequest()
        view?.load(request: request)
    }

    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }

    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }

    func shouldHideProgress(for value: Float) -> Bool {
        (1 - value) <= 0.0001
    }
}
