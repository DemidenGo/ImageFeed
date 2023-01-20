//
//  AuthHelperTests.swift
//  ImageFeedTests
//
//  Created by Юрий Демиденко on 20.01.2023.
//

import XCTest
@testable import ImageFeed

final class AuthHelperTests: XCTestCase {

    func testAuthURL() {
        // Given
        let authHelper = AuthHelper()

        // When
        let url = authHelper.authURL()
        let urlString = url.absoluteString

        // Then
        XCTAssertTrue(urlString.contains(Constants.unsplashAuthorizeURLString))
        XCTAssertTrue(urlString.contains(Constants.accessKey))
        XCTAssertTrue(urlString.contains(Constants.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(Constants.accessScope))
    }

    func testCodeFromUrl() {
        // Given
        let authHelper = AuthHelper()
        var urlComponents = URLComponents()
        urlComponents.path = "/oauth/authorize/native"
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "testValue")]
        guard let url = urlComponents.url else { return }

        // When
        let code = authHelper.code(from: url)

        // Then
        XCTAssertEqual(code, "testValue")
    }
}
