//
//  ViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 27.10.2022.
//

import UIKit

// MARK: - UIViewController

final class ImagesListViewController: UIViewController {

    private lazy var imagesListService: ImagesListServiceProtocol = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    private let placeholderImage = UIImage(named: "PlaceholderImageForFeed.png")
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var photoNames = Array(0...19).map { "\($0)" }
    private lazy var photos = [Photo]()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

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
            let photoName = photoNames[indexPath.row]
            let image = UIImage(named: "\(photoName)_full_size") ?? UIImage(named: photoName)
            viewController?.singleImageView.image = image
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
        guard let loadedPhoto = imagesListService.photos[safe: indexPath.row],
              let url = URL(string: loadedPhoto.thumbImageURL),
              let placeholderImageHeight = placeholderImage?.size.height else {
            print("Error: unable to get thumb photo URL from photos array")
            imagesListService.fetchNextPageOfPhotos()
            return
        }
        let loadedPhotoHeight = loadedPhoto.size.height
        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholderImage) { _ in
            if loadedPhotoHeight != placeholderImageHeight {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
