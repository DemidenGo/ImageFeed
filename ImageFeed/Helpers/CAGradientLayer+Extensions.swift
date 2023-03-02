//
//  CAGradientLayer+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 16.01.2023.
//

import UIKit

extension CAGradientLayer {
    static func makeGradientLayerWithAnimation(size: CGSize) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = 16
        gradient.masksToBounds = true

        let gradientLocationsAnimation = CABasicAnimation(keyPath: "locations")
        gradientLocationsAnimation.duration = 1
        gradientLocationsAnimation.repeatCount = .infinity
        gradientLocationsAnimation.fromValue = [0, 0.1, 0.3]
        gradientLocationsAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientLocationsAnimation, forKey: "locationsAnimation")

        return gradient
    }
}
