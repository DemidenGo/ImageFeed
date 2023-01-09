//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 06.01.2023.
//

import UIKit
import AVFoundation

protocol ImagesListServiceProtocol {
    var lastLoadedPage: UInt { get }
    var photos: [Photo] { get }
    func fetchNextPageOfPhotos()
}

final class ImagesListService: ImagesListServiceProtocol {

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private var task: URLSessionTask?
    private(set) lazy var photos = [Photo]()
    private(set) lazy var lastLoadedPage: UInt = 0
    private var nextPage: UInt { lastLoadedPage + 1 }
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared

    func fetchNextPageOfPhotos() {
        guard task == nil else { return }
        let request = makeURLRequest()
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

    private func makeURLRequest() -> URLRequest {
        let baseURL = defaultBaseURL
        let imagesListURL = baseURL.appendingPathComponent("photos")
        guard let components = URLComponents(url: imagesListURL, resolvingAgainstBaseURL: false) else {
            preconditionFailure("Unable to construct imagesListURLComponents")
        }
        var imagesListURLComponents = components
        imagesListURLComponents.queryItems = [URLQueryItem(name: "page", value: String(nextPage))]
        guard let url = imagesListURLComponents.url else {
            preconditionFailure("Unable to construct imagesListURL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Authorization: Bearer \(tokenStorage.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
