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

    private lazy var tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage()
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: Profile?

    private enum NetworkError: Error {
        case codeError
    }

    func fetchProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastToken == tokenStorage.token { return }
        task?.cancel()
        lastToken = tokenStorage.token
        let request = makeURLRequest()
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            DispatchQueue.main.async {
                
                if let error = error {
                    print("ERROR:", error)
                    completion(.failure(error))
                    self.lastToken = nil
                    return
                }

                if let response = response as? HTTPURLResponse,
                   response.statusCode != 200 {
                    print("HTTP ERROR in ProfileService:", response.statusCode)
                    completion(.failure(NetworkError.codeError))
                    return
                }

                guard let data = data else { return }
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let jsonResponse = try decoder.decode(ProfileResult.self, from: data)
                    let profileResult = jsonResponse
                    let profile = Profile(username: profileResult.username,
                                          name: profileResult.firstName + " " + profileResult.lastName,
                                          loginName: "@" + profileResult.username,
                                          bio: profileResult.bio)
                    self.profile = profile
                    completion(.success(profile))
                    self.task = nil
                } catch {
                    print("DECODING ERROR:", error)
                    completion(.failure(error))
                    self.lastToken = nil
                }
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
