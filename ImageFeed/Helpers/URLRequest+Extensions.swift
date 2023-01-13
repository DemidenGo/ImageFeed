//
//  URLRequest+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 09.01.2023.
//

import UIKit

extension URLRequest {

    static func makeURLRequest(baseURL url: URL,
                               pathComponent component: String?,
                               queryItems items: [URLQueryItem]?,
                               requestHttpMethod method: String,
                               addValue value: String?,
                               forHTTPHeaderField headerField: String?) -> URLRequest {
        var fullURL: URL
        if let component = component {
            fullURL = url.appendingPathComponent(component)
        } else {
            fullURL = url
        }
        lazy var urlComponents = URLComponents()
        if let items = items,
           let valueComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: false) {
            urlComponents = valueComponents
            urlComponents.queryItems = items
            fullURL = urlComponents.url ?? fullURL
        }
        var request = URLRequest(url: fullURL)
        request.httpMethod = method
        if let value = value,
           let headerField = headerField {
            request.addValue(value, forHTTPHeaderField: headerField)
        }
        return request
    }
}
