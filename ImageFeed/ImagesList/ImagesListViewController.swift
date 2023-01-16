//
//  ViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 27.10.2022.
//

import UIKit
import ProgressHUD

// MARK: - UIViewController

final class ImagesListViewController: UIViewController {

    private var imagesListServiceObserver: NSObjectProtocol?
    private lazy var imagesListService: ImagesListServiceProtocol = ImagesListService.shared
    private lazy var errorAlertPresenter: ErrorAlertPresenterProtocol = ErrorAlertPresenter(viewController: self)    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var photos = [Photo]()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        addImagesListServiceObserver()
        imagesListService.fetchNextPageOfPhotos()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            let viewController = segue.destination as? SingleImageViewController
            let indexPath = sender as! IndexPath
            guard let largeImageURLString = photos[safe: indexPath.row]?.largeImageURL else {
                preconditionFailure("Unable to get largeImageURLString from photos array")
            }
            let largeImageURL = URL(string: largeImageURLString)
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
        let oldRowCount = photos.count
        let newRowCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldRowCount != newRowCount {
            tableView.performBatchUpdates {
                let newIndexPaths = (oldRowCount..<newRowCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: newIndexPaths, with: .automatic)
            } completion: { _ in }
        }
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let loadedPhoto = photos[safe: indexPath.row] else {
            preconditionFailure("ERROR: unable to get photo from photos array using cell indexPath")
        }
        let cellViewModel = loadedPhoto.convertToCellViewModel()
        cell.configure(with: cellViewModel) { [weak self] in
            if loadedPhoto.size != thumbImagePlaceholderSize {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.identifier, for: indexPath)

        guard let imagesListCell = cell as? ImagesListCell else {
            print("Type casting error for ImagesListCell")
            return UITableViewCell()
        }

        imagesListCell.delegate = self
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imagesListService.fetchNextPageOfPhotos()
        }
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {

    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = photos[safe: indexPath.row] else {
            preconditionFailure("Unable to found cell with clicked likeButton")
        }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success(_):
                guard let self = self else { return }
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                print("ERROR: unable to change photos like", error)
                let message = photo.isLiked ? "Не удалось снять лайк" : "Не удалось поставить лайк"
                self?.errorAlertPresenter.presentAlert(title: "Что-то пошло не так(",
                                                       message: message,
                                                       buttonTitles: "Ок") {  }
            }
        }
    }
}
