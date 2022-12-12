//
//  UIColor+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 08.11.2022.
//

import UIKit

extension UIColor {
    static var ypBlack: UIColor { UIColor(named: "YP Black") ?? .black }
    static var ypWhite: UIColor { UIColor(named: "YP White") ?? .white }
    static var ypWhiteAlpha50: UIColor { UIColor(named: "YP White (Alpha 50)") ?? .systemGray3 }
    static var ypRed: UIColor { UIColor(named: "YP Red") ?? .systemRed }
    static var ypGray: UIColor { UIColor(named: "YP Gray") ?? .systemGray3 }
    static var gradientStart: UIColor { UIColor(named: "Gradient Start") ?? .white }
    static var gradientEnd: UIColor { UIColor(named: "Gradient End") ?? .systemGray3 }
}
