//
//  Date+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 13.01.2023.
//

import UIKit

let unsplashDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return formatter
}()

let feedDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM yyyy"
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()

extension Date {
    var dateString: String { feedDateFormatter.string(from: self) }
}
