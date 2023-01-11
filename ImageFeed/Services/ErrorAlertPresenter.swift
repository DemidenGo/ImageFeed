//
//  ErrorAlertPresenter.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 31.12.2022.
//

import UIKit

protocol ErrorAlertPresenterProtocol {
    func presentAlert(title: String,
                      message: String,
                      buttonTitles: String...,
                      buttonActions: () -> Void...)
}

final class ErrorAlertPresenter: ErrorAlertPresenterProtocol {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    /// Presents an alert controller modally. After tapping on any button, alert will be hidden
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: Descriptive text that provides additional details about the reason for the alert
    ///   - buttonTitles: The text to use for the buttons title. Titles are separated by commas. At least one title is required. There may be two titles. If you want to use two buttons then second button title and second button action is required
    ///   - buttonActions: A blocks to execute when the user selects the actions. Actions are separated by commas. At least one action is required. There may be two actions. If you want to use two buttons then second button title and second button action is required
    func presentAlert(title: String,
                      message: String,
                      buttonTitles: String...,
                      buttonActions: () -> Void...) {

        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)

        guard let firstButtonTitle = buttonTitles[safe: 0], let firstButtonAction = buttonActions[safe: 0] else {
            preconditionFailure("Unable to get first button title or action in ErrorAlertPresenter")
        }
        let firstAction = UIAlertAction(title: firstButtonTitle, style: .default) { _ in
            alert.dismiss(animated: true)
            firstButtonAction()
        }
        alert.addAction(firstAction)

        if let secondButtonTitle = buttonTitles[safe: 1], let secondButtonAction = buttonActions[safe: 1] {
            let secondAction = UIAlertAction(title: secondButtonTitle, style: .default) { _ in
                alert.dismiss(animated: true)
                secondButtonAction()
            }
            alert.addAction(secondAction)
        }

        viewController?.present(alert, animated: true)
    }
}
