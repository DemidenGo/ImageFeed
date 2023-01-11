//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 06.01.2023.
//

import UIKit
import AVFoundation

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchNextPageOfPhotos()
    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListService: ImagesListServiceProtocol {

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private var task: URLSessionTask?
    private(set) lazy var photos = [Photo]()
    private(set) lazy var lastLoadedPage: UInt = 0
    private var nextPage: UInt { lastLoadedPage + 1 }
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared

    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let request = URLRequest.makeURLRequest(baseURL: defaultBaseURL,
                                                pathComponent: "/photos/\(photoID)/like",
                                                queryItems: nil,
                                                requestHttpMethod: isLike ? "POST" : "DELETE",
                                                addValue: "Authorization: Bearer \(tokenStorage.token)",
                                                forHTTPHeaderField: "Authorization")
        let task = session.objectTask(for: request) { [weak self] (result: Result<ResponseToLike, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    guard let self = self,
                          let index = self.photos.firstIndex(where: { $0.id == photoID }),
                          self.photos.indices ~= index else {
                        preconditionFailure("Unable to get correct index for liked photo")
                    }
                    self.photos[index].isLiked.toggle()
                    completion(.success(()))
                case .failure(let error):
                    print("ERROR: likes changing  failure", error)
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }

    func fetchNextPageOfPhotos() {
        guard task == nil else { return }
        let request = URLRequest.makeURLRequest(baseURL: defaultBaseURL,
                                                pathComponent: "photos",
                                                queryItems: [URLQueryItem(name: "page", value: String(nextPage))],
                                                requestHttpMethod: "GET",
                                                addValue: "Authorization: Bearer \(tokenStorage.token)",
                                                forHTTPHeaderField: "Authorization")
        let task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let jsonResponse):
                    for photoResult in jsonResponse {
                        let photo = Photo(id: photoResult.id,
                                          size: CGSize(width: Double(photoResult.width),
                                                       height: Double(photoResult.height)),
                                          createdAt: photoResult.createdAt,
                                          description: photoResult.description,
                                          thumbImageURL: photoResult.urls.thumb,
                                          largeImageURL: photoResult.urls.full,
                                          isLiked: photoResult.likedByUser)
                        self?.photos.append(photo)
                    }
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    self?.task = nil
                    self?.lastLoadedPage += 1
                case .failure(let error):
                    print("ERROR: unable to get jsonResponse for next page of photos. Error code: ", error)
                    self?.fetchNextPageOfPhotos()
                }
            }
        }
        self.task = task
        task.resume()
    }
}
