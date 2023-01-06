//
//  URLSession+Extensions.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 30.12.2022.
//

import UIKit

extension URLSession {

    private enum NetworkError: Error {
        case codeError
    }

    func objectTask<T: Decodable>(for request: URLRequest, completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {

        let fulfillCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in

            if let error = error {
                print("ERROR: \(error), URL request \(request.description) failure")
                fulfillCompletionOnMainThread(.failure(error))
                return
            }

            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                print("HTTP ERROR when trying to get data for \(T.self) model:", response.statusCode)
                fulfillCompletionOnMainThread(.failure(NetworkError.codeError))
                return
            }

            guard let data = data else {
                print("Data receiving error: \(NetworkError.codeError)")
                fulfillCompletionOnMainThread(.failure(NetworkError.codeError))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonResponse = try decoder.decode(T.self, from: data)
                fulfillCompletionOnMainThread(.success(jsonResponse))
            } catch {
                print("DECODING ERROR: \(error)")
                fulfillCompletionOnMainThread(.failure(error))
            }
        }
        return task
    }
}
