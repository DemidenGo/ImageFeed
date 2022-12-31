//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 05.12.2022.
//

import UIKit
import SwiftKeychainWrapper

protocol OAuth2TokenStorageProtocol {
    var token: String { get }
    func setTokenValue(newValue: String)
}

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {

    private enum Keys: String {
        case accessToken
    }

    var token: String {
        guard let token = KeychainWrapper.standard.string(forKey: Keys.accessToken.rawValue) else {
            print("ERROR: unable to get token value from Kaychain storage")
            return .init()
        }
        return token
    }

    func setTokenValue(newValue: String) {
        let isSuccess = KeychainWrapper.standard.set(newValue, forKey: Keys.accessToken.rawValue)
        guard isSuccess else {
            print("ERROR: unable to set new value in Kaychain storage")
            setTokenValue(newValue: newValue)
            return
        }
    }
}
