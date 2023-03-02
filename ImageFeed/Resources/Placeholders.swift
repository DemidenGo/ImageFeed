//
//  Placeholders.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 15.01.2023.
//

import UIKit

let thumbImagePlaceholder = UIImage(named: "PlaceholderImageForFeed.png")
let largeImagePlaceholder = UIImage(named: "LargeImagePlaceholder.png")
let avatarPlaceholder = UIImage(named: "AvatarPlaceholder.png")
var thumbImagePlaceholderSize: CGSize {
    guard let size = thumbImagePlaceholder?.size else {
        preconditionFailure("Unable to get size of thumbImagePlaceholder")
    }
    return size
}
