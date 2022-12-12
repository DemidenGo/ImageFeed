//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 05.12.2022.
//

import UIKit

protocol OAuth2TokenStorageProtocol {
    var token: String { get }
    func setTokenValue(newValue: String)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {

    private let userDefaults = UserDefaults.standard

    private enum Keys: String {
        case accessToken
    }

    private(set) var token: String {
        get {
            guard let token = userDefaults.string(forKey: Keys.accessToken.rawValue) else {
                print("Unable to get token value from local storage")
                return .init()
            }
            return token
        }
        set {
            userDefaults.set(newValue, forKey: Keys.accessToken.rawValue)
        }
    }

    func setTokenValue(newValue: String) {
        token = newValue
    }
}
