//
//  ImagesListCellDelegate.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 10.01.2023.
//

import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}
