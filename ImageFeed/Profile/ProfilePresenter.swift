//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 20.01.2023.
//

import UIKit
import WebKit

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func didUpdateProfileDetails()
    func didUpdateAvatar()
    func deleteCurrentAccessTokenAndCleanCash()
    func switchToSplashViewController()
}

final class ProfilePresenter: ProfilePresenterProtocol {

    var view: ProfileViewControllerProtocol?
    private lazy var profileService: ProfileServiceProtocol = ProfileService.shared
    private lazy var profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
    private lazy var tokenStorage: AuthTokenStorageProtocol = AuthTokenKeychainStorage.shared

    func didUpdateProfileDetails() {
        guard let profile = profileService.profile else { preconditionFailure("Unable to get user profile") }
        view?.removeGradientLayersFromProfileDetails()
        view?.setProfileDetails(name: profile.name, nickname: profile.loginName, bio: profile.bio)
    }

    func didUpdateAvatar() {
        guard
            let profileImageURL = profileImageService.avatarURL,
            let url = URL(string: profileImageURL)
        else { preconditionFailure("Unable to get profile image URL") }
        view?.setAvatar(url: url)
    }

    func deleteCurrentAccessTokenAndCleanCash() {
        tokenStorage.setTokenValue(newValue: "")
        WKWebView.clean()
    }

    func switchToSplashViewController() {
        window.rootViewController = SplashViewController()
        window.makeKeyAndVisible()
    }
}
