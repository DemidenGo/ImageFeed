//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Юрий Демиденко on 25.01.2023.
//

import XCTest
@testable import ImageFeed

// MARK: - Stubs

var urlStub: URL {
    guard let url = URL(string: "https://api.unsplash.com/") else {
        preconditionFailure("Unable to get urlStub")
    }
    return url
}
let cellViewModelStub = CellViewModel(thumbImageURL: urlStub, createdAt: "test", isLiked: false)
let indexPathStub = IndexPath(row: 0, section: 0)
let photoStub = Photo(id: "test",
                      size: CGSize(width: 100, height: 100),
                      createdAt: "2023-01-26T07:04:44Z",
                      description: "test",
                      thumbImageURL: "test",
                      largeImageURL: "test",
                      isLiked: false)

final class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos = [Photo]()
    var isChangeLikeReturnsSuccess: Bool

    init(isChangeLikeReturnsSuccess: Bool = true) {
        self.isChangeLikeReturnsSuccess = isChangeLikeReturnsSuccess
    }

    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        switch isChangeLikeReturnsSuccess {
        case true:
            photos[0].isLiked = isLike
            let void: Void
            completion(.success(void))
        case false:
            enum TestError: Error { case error }
            completion(.failure(TestError.error))
        }
    }

    func fetchNextPageOfPhotos() {
        photos.append(photoStub)
    }
}

// MARK: - Spies

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    let imagesListService: ImagesListServiceProtocol
    var photos = [Photo]()
    var fetchNextPageOfPhotosCalls = false
    var largeImageURLCalls = false
    var shouldUpdateTableViewCalls = false

    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    func fetchNextPageOfPhotos() {
        fetchNextPageOfPhotosCalls = true
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
    }

    func largeImageURL(for indexPath: IndexPath) -> URL? {
        largeImageURLCalls = true
        return nil
    }

    func shouldUpdateTableView() -> Bool {
        shouldUpdateTableViewCalls = true
        return false
    }

    func calculateNewIndexPaths() -> [IndexPath] { return [indexPathStub] }
    func shouldReloadTableRow(at indexPath: IndexPath) -> Bool { false }
    func prepareViewModelForCell(with: IndexPath) -> CellViewModel { cellViewModelStub }
    func shouldFetchNextPageOfPhotos(for indexPath: IndexPath) -> Bool {false}
    func changeLike(for cell: ImagesListCell, with indexPath: IndexPath) {   }
}

final class ImagesListViewControllerSpy: UIViewController, ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)  
    var setCellIsLikedCalls = false
    var presentAlertCalls = false

    func set(cell: ImagesListCell, isLiked: Bool) {
        setCellIsLikedCalls = true
    }

    func presentAlert(message: String) {
        presentAlertCalls = true
        errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                               message: message,
                                               buttonTitles: "Ок") {  }
    }
}

// MARK: - ImagesListTests

final class ImagesListTests: XCTestCase {

    // MARK: - Test ViewController calls Presenter

    func testViewControllerCallsFetchNextPageOfPhotos() {
        // Given
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            preconditionFailure("Unable to get tabBarController from Storyboard")
        }
        guard let imagesListViewController = tabBarController.viewControllers?[0] as? ImagesListViewController else {
            preconditionFailure("Unable to get imagesListViewController from tabBarController")
        }
        let imagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController

        // When
        _ = imagesListViewController.view

        // Then
        XCTAssertTrue(imagesListPresenter.fetchNextPageOfPhotosCalls)
    }

    func testViewControllerCallsLargeImageURL() {
        // Given
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            preconditionFailure("Unable to get tabBarController from Storyboard")
        }
        guard let imagesListViewController = tabBarController.viewControllers?[0] as? ImagesListViewController else {
            preconditionFailure("Unable to get imagesListViewController from tabBarController")
        }
        let imagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        let segueStub = UIStoryboardSegue(identifier: "ShowSingleImage",
                                          source: imagesListViewController,
                                          destination: SingleImageViewController())

        // When
        imagesListViewController.performSegue(withIdentifier: "ShowSingleImage", sender: indexPathStub)
        imagesListViewController.prepare(for: segueStub, sender: indexPathStub)

        // Then
        XCTAssertTrue(imagesListPresenter.largeImageURLCalls)
    }

    func testViewControllerCallsShouldUpdateTableView() {
        // Given
        guard let tabBarController = mainStoryboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else {
            preconditionFailure("Unable to get tabBarController from Storyboard")
        }
        guard let imagesListViewController = tabBarController.viewControllers?[0] as? ImagesListViewController else {
            preconditionFailure("Unable to get imagesListViewController from tabBarController")
        }
        let imagesListPresenter = ImagesListPresenterSpy()
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController

        // When
        _ = imagesListViewController.view

        // Then
        XCTAssertTrue(imagesListPresenter.shouldUpdateTableViewCalls)
    }

    // MARK: - Test Presenter calls ViewController

    func testPresenterCallsSetCellIsLiked() {
        // Given
        let imagesListViewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceStub()
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService)
        imagesListPresenter.view = imagesListViewController
        imagesListService.fetchNextPageOfPhotos()
        imagesListPresenter.photos.append(photoStub)

        // When
        imagesListPresenter.changeLike(for: ImagesListCell(), with: indexPathStub)

        // Then
        XCTAssertTrue(imagesListViewController.setCellIsLikedCalls)
    }

    func testPresenterCallsPresentAlert() {
        // Given
        let imagesListViewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceStub(isChangeLikeReturnsSuccess: false)
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService)
        imagesListPresenter.view = imagesListViewController
        imagesListService.fetchNextPageOfPhotos()
        imagesListPresenter.photos.append(photoStub)

        // When
        imagesListPresenter.changeLike(for: ImagesListCell(), with: indexPathStub)

        // Then
        XCTAssertTrue(imagesListViewController.presentAlertCalls)
    }

    // MARK: - Test Presenter funcs

    func testNeedUpdateTableView() {
        // Given
        let imagesListServiceStub = ImagesListServiceStub()
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListServiceStub)

        // When
        for _ in 0...9 {
            imagesListServiceStub.photos.append(photoStub)
        }
        
        // Then
        XCTAssertTrue(imagesListPresenter.shouldUpdateTableView())
    }

    func testNotNeedUpdateTableView() {
        // Given
        let imagesListServiceStub = ImagesListServiceStub()
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListServiceStub)

        // When
        imagesListServiceStub.photos = []

        // Then
        XCTAssertFalse(imagesListPresenter.shouldUpdateTableView())
    }

    func testCalculateNewIndexPaths() {
        // Given
        let imagesListPresenter = ImagesListPresenter()
        imagesListPresenter.oldRowCount = 0
        imagesListPresenter.newRowCount = 10

        // When
        let newIndexPaths = imagesListPresenter.calculateNewIndexPaths()

        // Then
        XCTAssertEqual(newIndexPaths.count, 10)
    }

    func testNeedReloadTableRow() {
        // Given
        // Placeholder size - (343.0, 252.0)
        let imagesListPresenter = ImagesListPresenter()
        let photo = Photo(id: "test",
                          size: CGSize(width: 400, height: 300),
                          createdAt: "test",
                          description: "test",
                          thumbImageURL: "test",
                          largeImageURL: "test",
                          isLiked: false)
        imagesListPresenter.photos.append(photo)

        // When
        let isNeed = imagesListPresenter.shouldReloadTableRow(at: indexPathStub)

        // Then
        XCTAssertTrue(isNeed)
    }

    func testNotNeedReloadTableRow() {
        // Given
        // Placeholder size - (343.0, 252.0)
        let imagesListPresenter = ImagesListPresenter()
        let photo = Photo(id: "test",
                          size: CGSize(width: 343, height: 252),
                          createdAt: "test",
                          description: "test",
                          thumbImageURL: "test",
                          largeImageURL: "test",
                          isLiked: false)
        imagesListPresenter.photos.append(photo)

        // When
        let isNeed = imagesListPresenter.shouldReloadTableRow(at: indexPathStub)

        // Then
        XCTAssertFalse(isNeed)
    }

    func testNeedFetchNextPageOfPhotos() {
        // Given
        let imagesListPresenter = ImagesListPresenter()
        let indexPath = IndexPath(row: 9, section: 0)
        for _ in 0...9 {
            imagesListPresenter.photos.append(photoStub)
        }

        // When
        let isNeed = imagesListPresenter.shouldFetchNextPageOfPhotos(for: indexPath)

        // Then
        XCTAssertTrue(isNeed)
    }

    func testNotNeedFetchNextPageOfPhotos() {
        // Given
        let imagesListPresenter = ImagesListPresenter()
        let indexPath = IndexPath(row: 8, section: 0)
        for _ in 0...9 {
            imagesListPresenter.photos.append(photoStub)
        }

        // When
        let isNeed = imagesListPresenter.shouldFetchNextPageOfPhotos(for: indexPath)

        // Then
        XCTAssertFalse(isNeed)
    }

    func testChangeLikeForCell() {
        // Given
        let imagesListService = ImagesListServiceStub()
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService)
        // Append not liked photo with isLiked = false
        imagesListService.fetchNextPageOfPhotos()
        imagesListPresenter.photos.append(photoStub)

        // When
        imagesListPresenter.changeLike(for: ImagesListCell(), with: indexPathStub)

        // Then
        XCTAssertTrue(imagesListPresenter.photos[0].isLiked)
    }

    // MARK: - Test ViewController funcs

    func testPresentAlert() {
        // Given
        let imagesListViewController = ImagesListViewControllerSpy()
        let imagesListService = ImagesListServiceStub(isChangeLikeReturnsSuccess: false)
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService)
        imagesListPresenter.view = imagesListViewController
        imagesListService.fetchNextPageOfPhotos()
        imagesListPresenter.photos.append(photoStub)
        window.rootViewController = imagesListViewController
        window.makeKeyAndVisible()

        // When
        imagesListPresenter.changeLike(for: ImagesListCell(), with: indexPathStub)

        // Then
        XCTAssertTrue(imagesListViewController.presentedViewController is UIAlertController)
        XCTAssertEqual(imagesListViewController.presentedViewController?.title, "Что-то пошло не так(")
    }
}
