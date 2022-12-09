//
//  UserProfile.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 07.12.2022.
//

import UIKit

struct UserProfile: Decodable {
    let id: String
    let updatedAt: String
    let username: String
    let firstName: String
    let lastName: String
    let twitterUsername: String?
    let portfolioURLString: String?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let followedByUser: Bool
    let downloads: Int
    let uploadsRemaining: Int
    let instagramUsername: String?
    let email: String?
    let links: Links

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case updatedAt = "updated_at"
        case username = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case twitterUsername = "twitter_username"
        case portfolioURLString = "portfolio_url"
        case bio = "bio"
        case location = "location"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case followedByUser = "followed_by_user"
        case downloads = "downloads"
        case uploadsRemaining = "uploads_remaining"
        case instagramUsername = "instagram_username"
        case email = "email"
        case links = "links"
    }
}

struct Links: Decodable {
    let `self`: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
}
