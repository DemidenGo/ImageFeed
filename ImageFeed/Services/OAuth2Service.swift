//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 03.12.2022.
//

import UIKit

//MARK: - OAuth2Protocol

protocol AuthServiceProtocol {
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void)
}

//MARK: - OAuth2Service

final class OAuth2Service: AuthServiceProtocol {

    private var task: URLSessionTask?
    private var lastCode: String?

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        let request = URLRequest.makeURLRequest(baseURL: unsplashTokenURL,
                                                pathComponent: nil,
                                                queryItems: [
                                                    URLQueryItem(name: "client_id", value: accessKey),
                                                    URLQueryItem(name: "client_secret", value: secretKey),
                                                    URLQueryItem(name: "redirect_uri", value: redirectURI),
                                                    URLQueryItem(name: "code", value: code),
                                                    URLQueryItem(name: "grant_type", value: "authorization_code")
                                                ],
                                                requestHttpMethod: "POST",
                                                addValue: nil,
                                                forHTTPHeaderField: nil)
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let jsonResponse):
                let accessToken = jsonResponse.accessToken
                completion(.success(accessToken))
                self?.task = nil
            case .failure(let error):
                completion(.failure(error))
                self?.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
}
