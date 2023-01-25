//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Юрий Демиденко on 24.01.2023.
//

import XCTest
@testable import ImageFeed

let profileStub = Profile(username: "test", name: "test", loginName: "test", bio: "test")
let profileImageURLStringStub = "https://api.unsplash.com/"

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    var didUpdateProfileDetailsCalls = false
    var didUpdateAvatarCalls = false

    func didUpdateProfileDetails() {
        didUpdateProfileDetailsCalls = true
    }

    func didUpdateAvatar() {
        didUpdateAvatarCalls = true
    }

    func deleteCurrentAccessTokenAndCleanCash() {   }
    func switchToSplashViewController() {   }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var setProfileDetailsCalls = false
    var setAvatarCalls = false

    func setProfileDetails(name: String, nickname: String, bio: String?) {
        setProfileDetailsCalls = true
    }

    func setAvatar(url: URL) {
        setAvatarCalls = true
    }

    func removeGradientLayersFromProfileDetails() {   }
}

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?
    func fetchProfile(_ completion: @escaping (Result<Profile, Error>) -> Void) {   }
}

final class ProfileImageServiceStub: ProfileImageServiceProtocol {
    var avatarURL: String?
    func fetchProfileImageURL(for username: String, _ completion: @escaping (Result<String, Error>) -> Void) {  }
}

final class ProfileViewTests: XCTestCase {

    func testViewControllerCallsDidUpdateProfileDetails() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenter.didUpdateProfileDetailsCalls)
    }

    func testViewControllerCallsDidUpdateAvatar() {
        // Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        _ = viewController.view

        // Then
        XCTAssertTrue(presenter.didUpdateAvatarCalls)
    }

    func testPresenterCallsSetProfileDetails() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceStub()
        profileService.profile = profileStub
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: ProfileImageService.shared,
                                         tokenStorage: AuthTokenKeychainStorage.shared)
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.didUpdateProfileDetails()

        // Then
        XCTAssertTrue(viewController.setProfileDetailsCalls)
    }

    func testPresenterCallsSetAvatar() {
        // Given
        let viewController = ProfileViewControllerSpy()
        let profileImageService = ProfileImageServiceStub()
        profileImageService.avatarURL = profileImageURLStringStub
        let presenter = ProfilePresenter(profileService: ProfileService.shared,
                                         profileImageService: profileImageService,
                                         tokenStorage: AuthTokenKeychainStorage.shared)
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.didUpdateAvatar()

        // Then
        XCTAssertTrue(viewController.setAvatarCalls)
    }

    func testRemoveGradientLayers() {
        // Given
        let viewController = ProfileViewController()
        let profileService = ProfileServiceStub()
        profileService.profile = profileStub
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: ProfileImageService.shared,
                                         tokenStorage: AuthTokenKeychainStorage.shared)
        viewController.presenter = presenter
        presenter.view = viewController

        // When
        presenter.didUpdateProfileDetails()
        let nameLabelSublayers = viewController.nameLabel.layer.sublayers ?? []
        let nicknameLabelSublayers = viewController.nicknameLabel.layer.sublayers ?? []
        let statusLabelSublayers = viewController.statusLabel.layer.sublayers ?? []

        // Then
        XCTAssertTrue(nameLabelSublayers.isEmpty)
        XCTAssertTrue(nicknameLabelSublayers.isEmpty)
        XCTAssertTrue(statusLabelSublayers.isEmpty)
    }
}
