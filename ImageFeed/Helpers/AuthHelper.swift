//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 20.01.2023.
//

import UIKit

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {

    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest {
        let url = authURL()
        return URLRequest(url: url)
    }

    func code(from url: URL) -> String? {
        if
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }

    private func authURL() -> URL {
        guard let components = URLComponents(string: configuration.authURLString) else {
            preconditionFailure("Unable to construct unsplashAuthorizeURLComponents")
        }
        var unsplashURLComponents = components
        unsplashURLComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        guard let url = unsplashURLComponents.url else {
            preconditionFailure("Unable to construct unsplashAuthorizeURL")
        }
        return url
    }
}
