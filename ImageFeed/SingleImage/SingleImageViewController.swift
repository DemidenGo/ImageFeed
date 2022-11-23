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

    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "Backward")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(backwardButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        layout()
    }

    @objc private func backwardButtonAction() {
        dismiss(animated: true)
    }

    private func layout() {
        [singleImageView, backwardButton].forEach { view.addSubview($0) }
        NSLayoutConstraint.activate([
            singleImageView.topAnchor.constraint(equalTo: view.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9)
        ])
    }
}
