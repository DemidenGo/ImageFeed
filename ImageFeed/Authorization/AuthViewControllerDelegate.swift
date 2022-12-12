//
//  AuthViewControllerDelegateProtocol.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 08.12.2022.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewControllerDelegate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}
