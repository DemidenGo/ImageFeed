//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 28.12.2022.
//

import UIKit

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ completion: @escaping (Result<Profile, Error>) -> Void)
}

final class ProfileService: ProfileServiceProtocol {

    static let shared = ProfileService()

    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?

    func fetchProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == tokenStorage.token { return }
        task?.cancel()
        lastToken = tokenStorage.token
        let request = makeURLRequest()
        let task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let jsonResponse):
                let profileResult = jsonResponse
                let profile = Profile(username: profileResult.username,
                                      name: profileResult.firstName + " " + profileResult.lastName,
                                      loginName: "@" + profileResult.username,
                                      bio: profileResult.bio)
                self?.profile = profile
                completion(.success(profile))
                self?.task = nil
            case .failure(let error):
                completion(.failure(error))
                self?.lastToken = nil
            }
        }
        self.task = task
        task.resume()
    }

    private func makeURLRequest() -> URLRequest {
        let baseURL = defaultBaseURL
        let profileURL = baseURL.appendingPathComponent("me")
        var request = URLRequest(url: profileURL)
        request.httpMethod = "GET"
        request.addValue("Authorization: Bearer \(tokenStorage.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
