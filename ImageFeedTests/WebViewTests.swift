//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Юрий Демиденко on 20.01.2023.
//

import XCTest
@testable import ImageFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {

    var viewDidLoadCalled = false
    var view: WebViewViewControllerProtocol?

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didUpdateProgressValue(_ newValue: Double) {   }

    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {

    var loadRequestCalled = false
    var presenter: WebViewPresenterProtocol?

    func load(request: URLRequest) {
        loadRequestCalled = true
    }

    func setProgressValue(_ newValue: Float) {   }
    func setProgressHidden(_ isHidden: Bool) {   }
}

final class WebViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        // Given
        let viewController = WebViewViewController()
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }

    func testPresenterCallsLoadRequest() {
        // Given
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.viewDidLoad()

        // Then
        XCTAssertTrue(viewController.loadRequestCalled)
    }

    func testProgressVisibleWhenLessThenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progressValue: Float = 0.8

        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progressValue)

        // Then
        XCTAssertFalse(shouldHideProgress)
    }

    func testProgressHiddenWhenOne() {
        // Given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progressValue: Float = 1

        // When
        let shouldHideProgress = presenter.shouldHideProgress(for: progressValue)

        // Then
        XCTAssertTrue(shouldHideProgress)
    }
}
