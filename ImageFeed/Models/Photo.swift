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
    var isLiked: Bool
}

struct ResponseToLike: Decodable {
    
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

extension PhotoResult {
    func convertToViewModel() -> Photo {
        Photo(id: self.id,
              size: CGSize(width: Double(self.width), height: Double(self.height)),
              createdAt: self.createdAt,
              description: self.description,
              thumbImageURL: self.urls.thumb,
              largeImageURL: self.urls.full,
              isLiked: self.likedByUser)
    }
}

extension Photo {
    func convertToCellViewModel() -> CellViewModel {
        guard let url = URL(string: self.thumbImageURL) else {
            preconditionFailure("ERROR: unable to get URL from thumbImageURL string")
        }
        guard let date = unsplashDateFormatter.date(from: self.createdAt) else {
            preconditionFailure("ERROR: unable to get date from createdAt string")
        }
        return CellViewModel(thumbImageURL: url,
                      createdAt: date.dateString,
                      isLiked: self.isLiked)
    }
}
