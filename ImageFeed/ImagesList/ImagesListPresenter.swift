//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 25.01.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    var shouldUpdateTableView: Bool { get }
    var newIndexPaths: [IndexPath] { get }
    func largeImageURL(for indexPath: IndexPath) -> URL?
    func prepareViewModelForCell(with: IndexPath) -> CellViewModel
    func fetchNextPageOfPhotos()
    func shouldFetchNextPageOfPhotos(for indexPath: IndexPath) -> Bool
    func changeLike(for cell: ImagesListCell, with indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    lazy var photos = [Photo]()
    private let imagesListService: ImagesListServiceProtocol
    private lazy var oldRowCount = 0
    private lazy var newRowCount = 0

    var shouldUpdateTableView: Bool {
        oldRowCount = photos.count
        newRowCount = imagesListService.photos.count
        photos = imagesListService.photos
        return oldRowCount != newRowCount
    }

    var newIndexPaths: [IndexPath] {
        let newIndexPaths = (oldRowCount..<newRowCount).map { i in
            IndexPath(row: i, section: 0)
        }
        return newIndexPaths
    }

    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    func largeImageURL(for indexPath: IndexPath) -> URL? {
        guard let largeImageURLString = photos[safe: indexPath.row]?.largeImageURL else {
            preconditionFailure("Unable to get largeImageURLString from photos array")
        }
        let largeImageURL = URL(string: largeImageURLString)
        return largeImageURL
    }

    func prepareViewModelForCell(with indexPath: IndexPath) -> CellViewModel {
        let loadedPhoto = safeUnwrapLoadedPhoto(at: indexPath)
        return loadedPhoto.convertToCellViewModel()
    }

    func fetchNextPageOfPhotos() {
        imagesListService.fetchNextPageOfPhotos()
    }

    func shouldFetchNextPageOfPhotos(for indexPath: IndexPath) -> Bool {
        indexPath.row + 1 == photos.count
    }

    func changeLike(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = safeUnwrapLoadedPhoto(at: indexPath)
        imagesListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
            switch result {
            case .success(_):
                guard let self = self else { return }
                self.photos = self.imagesListService.photos
                let isLike = self.photos[indexPath.row].isLiked
                self.view?.set(cell: cell, isLiked: isLike)
            case .failure(let error):
                print("ERROR: unable to change photos like", error)
                let message = photo.isLiked ? "Не удалось снять лайк" : "Не удалось поставить лайк"
                self?.view?.presentAlert(message: message)
            }
        }
    }

    private func safeUnwrapLoadedPhoto(at indexPath: IndexPath) -> Photo {
        guard let photo = photos[safe: indexPath.row] else {
            preconditionFailure("ERROR: unable to get photo from photos array using cell indexPath")
        }
        return photo
    }
}
