//
//  Simplifiers.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 24.01.2023.
//

import UIKit

let session = URLSession.shared

let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)

var window: UIWindow {
    guard let window = UIApplication.shared.windows.first else {
        fatalError("Invalid Configuration: unable to get window from UIApplication")
    }
    return window
}

var screenWidth: CGFloat {
    UIScreen.main.bounds.width
}
