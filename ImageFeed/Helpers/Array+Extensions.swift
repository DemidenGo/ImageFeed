//
//  Array+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 09.01.2023.
//

import UIKit

extension Array {
    subscript(safe index: Index) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
