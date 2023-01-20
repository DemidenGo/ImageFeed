//
//  Constants.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 28.11.2022.
//

import Foundation

enum Constants {
    static let accessKey = "ie9E2359VCZSWY4fnVp4sVR9eO5zYGcFvjbTEjdl-wA"
    static let secretKey = "kFR-aYDvNyfGThFkHcTIRbEtsED93jvvGcZ937JFqWc"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let unsplashTokenURLString = "https://unsplash.com/oauth/token"
    static var unsplashTokenURL: URL {
        guard let url = URL(string: unsplashTokenURLString) else {
            preconditionFailure("Unable to construct unsplashTokenURL")
        }
        return url
    }
    static var defaultBaseURL: URL {
        guard let url = URL(string: "https://api.unsplash.com/") else {
            preconditionFailure("Unable to construct defaultBaseURL")
        }
        return url
    }
}

let session = URLSession.shared

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    static var standard: AuthConfiguration {
        AuthConfiguration(accessKey: Constants.accessKey,
                          secretKey: Constants.secretKey,
                          redirectURI: Constants.redirectURI,
                          accessScope: Constants.accessScope,
                          defaultBaseURL: Constants.defaultBaseURL,
                          authURLString: Constants.unsplashAuthorizeURLString)
    }

    init(accessKey: String,
         secretKey: String,
         redirectURI: String,
         accessScope: String,
         defaultBaseURL: URL,
         authURLString: String)
    {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
