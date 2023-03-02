//
//  ViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 27.10.2022.
//

import UIKit
import ProgressHUD

protocol ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol? { get set }
    func set(cell: ImagesListCell, isLiked: Bool)
    func presentAlert(message: String)
}

// MARK: - UIViewController

final class ImagesListViewController: UIViewController {

    private var state: DisplayState = .loading
    var presenter: ImagesListPresenterProtocol?
    var strongPresenter: ImagesListPresenterProtocol {
        guard let presenter = presenter else {
            preconditionFailure("Unable to get ImagesListPresenter")
        }
        return presenter
    }
    private var imagesListServiceObserver: NSObjectProtocol?
    private lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"

    private enum DisplayState {
        case loading
        case success
    }

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addImagesListServiceObserver()
        strongPresenter.fetchNextPageOfPhotos()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ProgressHUD.dismiss()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as! IndexPath
            let largeImageURL = strongPresenter.largeImageURL(for: indexPath)
            ProgressHUD.show()
            viewController?.singleImageView.kf.setImage(with: largeImageURL, placeholder: largeImagePlaceholder) { _ in
                viewController?.rescaleAndCenterImageInScrollView(image: viewController?.singleImageView.image)
                ProgressHUD.dismiss()
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.identifier)
        tableView.register(GradientCell.self, forCellReuseIdentifier: GradientCell.identifier)
    }

    private func addImagesListServiceObserver() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main) { [weak self] _ in
                    self?.updateTableViewAnimated()
                }
    }

    private func updateTableViewAnimated() {
        if strongPresenter.shouldUpdateTableView {
            tableView.performBatchUpdates {
                let newIndexPaths = strongPresenter.newIndexPaths
                tableView.insertRows(at: newIndexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        state = .loading
        let cellViewModel = strongPresenter.prepareViewModelForCell(with: indexPath)
        cell.configure(with: cellViewModel) { [weak self] in
            self?.state = .success
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strongPresenter.photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.identifier, for: indexPath)
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Type casting error for ImagesListCell")
            return UITableViewCell()
        }
        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)

        switch state {
        case .loading:
            let gradientCell = tableView.dequeueReusableCell(withIdentifier: GradientCell.identifier, for: indexPath)
            return gradientCell
        case .success:
            return imagesListCell
        }
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let shouldFetchNextPageOfPhotos = strongPresenter.shouldFetchNextPageOfPhotos(for: indexPath)
        if shouldFetchNextPageOfPhotos {
            strongPresenter.fetchNextPageOfPhotos()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {

    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            preconditionFailure("Unable to get indexPath for cell with clicked likeButton")
        }
        UIBlockingProgressHUD.show()
        strongPresenter.changeLike(for: cell, with: indexPath)
    }
}

// MARK: - ImagesListViewControllerProtocol

extension ImagesListViewController: ImagesListViewControllerProtocol {

    func set(cell: ImagesListCell, isLiked: Bool) {
        cell.setIsLiked(isLiked)
        UIBlockingProgressHUD.dismiss()
    }

    func presentAlert(message: String) {
        UIBlockingProgressHUD.dismiss()
        errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                               message: message,
                                               buttonTitles: "Ок") {  }
    }
}
