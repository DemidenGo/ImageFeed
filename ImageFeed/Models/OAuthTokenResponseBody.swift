//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 03.12.2022.
//

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
