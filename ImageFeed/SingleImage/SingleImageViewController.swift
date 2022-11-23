//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 18.11.2022.
//

import UIKit

class SingleImageViewController: UIViewController {

    lazy var singleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "0")
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        layout()
    }

    private func layout() {
        view.addSubview(singleImageView)
        NSLayoutConstraint.activate([
            singleImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}
