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
    private lazy var tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private(set) var avatarURL: String?

    private enum NetworkError: Error {
        case codeError
    }

    func fetchProfileImageURL(for username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastUsername == username { return }
        task?.cancel()
        lastUsername = username
        let request = makeURLRequest()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {

                if let error = error {
                    print("ERROR:", error)
                    completion(.failure(error))
                    self.lastUsername = nil
                    return
                }

                if let response = response as? HTTPURLResponse,
                   response.statusCode != 200 {
                    print("HTTP ERROR in ProfileImageService:", response.statusCode)
                    completion(.failure(NetworkError.codeError))
                    return
                }

                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let jsonResponse = try decoder.decode(UserResult.self, from: data)
                    let profileImageURL = jsonResponse.profileImage.small
                    self.avatarURL = profileImageURL
                    completion(.success(profileImageURL))
                    self.task = nil
                } catch {
                    print("DECODING ERROR:", error)
                    completion(.failure(error))
                    self.lastUsername = nil
                }
            }
        }
        self.task = task
        task.resume()
    }

    private func makeURLRequest() -> URLRequest {
        let baseURL = defaultBaseURL
        guard let username = profileService.profile?.username else {
            preconditionFailure("Unable to get username")
        }
        let publicProfileURL = baseURL.appendingPathComponent("users/\(username)")
        var request = URLRequest(url: publicProfileURL)
        request.httpMethod = "GET"
        request.addValue("Authorization: Bearer \(tokenStorage.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
