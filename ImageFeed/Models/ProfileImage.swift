//
//  ProfileImage.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 29.12.2022.
//

import UIKit

struct UserResult: Decodable {
    let profileImage: ProfileImage
}

struct ProfileImage: Decodable {
    let small: String
    let medium: String
    let large: String
}
