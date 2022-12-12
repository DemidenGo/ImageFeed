//
//  Constants.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 28.11.2022.
//

import Foundation

let accessKey = "ie9E2359VCZSWY4fnVp4sVR9eO5zYGcFvjbTEjdl-wA"
let secretKey = "kFR-aYDvNyfGThFkHcTIRbEtsED93jvvGcZ937JFqWc"
let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
let accessScope = "public+read_user+write_likes"
var defaultBaseURL: URL {
    guard let url = URL(string: "https://api.unsplash.com/") else {
        preconditionFailure("Unable to construct defaultBaseURL")
    }
    return url
}
