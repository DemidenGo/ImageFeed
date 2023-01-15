//
//  Profile.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 28.12.2022.
//

import UIKit

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

struct ProfileResult: Decodable {
    let id: String
    let updatedAt: String
    let username: String
    let firstName: String
    let lastName: String
    let twitterUsername: String?
    let portfolioUrl: String?
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
}

struct Links: Decodable {
    let `self`: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
}

extension ProfileResult {
    func convertToViewModel() -> Profile {
        Profile(username: self.username,
                name: self.firstName + " " + self.lastName,
                loginName: "@" + self.username,
                bio: self.bio)
    }
}
