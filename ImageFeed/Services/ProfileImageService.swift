//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 29.12.2022.
//

import UIKit

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImageURL(for username: String, _ completion: @escaping (Result<String, Error>) -> Void)
}

final class ProfileImageService: ProfileImageServiceProtocol {

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")

    private var task: URLSessionTask?
    private var lastUsername: String?
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared
    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private(set) var avatarURL: String?

    func fetchProfileImageURL(for username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUsername == username { return }
        task?.cancel()
        lastUsername = username
        guard let username = profileService.profile?.username else {
            preconditionFailure("Unable to get username")
        }
        let request = URLRequest.makeURLRequest(baseURL: defaultBaseURL,
                                                pathComponent: "users/\(username)",
                                                queryItems: nil,
                                                requestHttpMethod: "GET",
                                                addValue: "Authorization: Bearer \(tokenStorage.token)",
                                                forHTTPHeaderField: "Authorization")
        let task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let jsonResponse):
                let profileImageURL = jsonResponse.profileImage.small
                self?.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                self?.task = nil
            case .failure(let error):
                completion(.failure(error))
                self?.lastUsername = nil
            }
        }
        self.task = task
        task.resume()
    }
}
