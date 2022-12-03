//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 01.12.2022.
//

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
