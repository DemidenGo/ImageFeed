//
//  Photo.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 06.01.2023.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: String
    let description: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let width: UInt
    let height: UInt
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let thumb: String
    let full: String
}
