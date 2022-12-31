//
//  ErrorAlertPresenter.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 31.12.2022.
//

import UIKit

protocol ErrorAlertPresenterProtocol {
    func presentAlert(buttonAction: @escaping () -> Void)
}

final class ErrorAlertPresenter: ErrorAlertPresenterProtocol {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func presentAlert(buttonAction: @escaping () -> Void) {
        let alert = UIAlertController(title: "Что-то пошло не так...",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { _ in
            buttonAction()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
}
