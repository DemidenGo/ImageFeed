//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 18.11.2022.
//

import UIKit

class SingleImageViewController: UIViewController {

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.minimumZoomScale = 0.1
        view.maximumZoomScale = 1.25
        view.delegate = self
        return view
    }()

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

    private lazy var sharingButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = UIImage(named: "Sharing")
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(sharingButtonAction), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        layout()
        rescaleAndCenterImageInScrollView(image: singleImageView.image)
    }

    @objc private func backwardButtonAction() {
        dismiss(animated: true)
    }

    @objc private func sharingButtonAction() {
        guard let image = singleImageView.image else { return }
        let viewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(viewController, animated: true)
    }

    private func rescaleAndCenterImageInScrollView(image: UIImage?) {
        guard let image = image else { return }
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let hScale = visibleRectSize.width / image.size.width
        let vScale = visibleRectSize.height / image.size.height
        let theoreticalScale = max(hScale, vScale)
        let scale = min(scrollView.maximumZoomScale, max(scrollView.minimumZoomScale, theoreticalScale))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let contentOffsetX = (newContentSize.width - visibleRectSize.width) / 2
        let contentOffsetY = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: contentOffsetX, y: contentOffsetY), animated: false)
    }

    private func layout() {
        [scrollView, backwardButton, sharingButton].forEach { view.addSubview($0) }
        scrollView.addSubview(singleImageView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            singleImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            singleImageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),

            backwardButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 9),
            backwardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 9),

            sharingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sharingButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
        ])
    }
}

//MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return singleImageView
    }
}
