//
//  ViewController.swift
//  ImageFeed
//
//  Created by Юрий Демиденко on 27.10.2022.
//

import UIKit

// MARK: - UIViewController

final class ImagesListViewController: UIViewController {

    private lazy var photosName = Array(0...19).map { "\($0)" }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.identifier)
    }

    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        cell.photoImageView.image = UIImage(named: photosName[indexPath.row])
        cell.dateLabel.text = dateFormatter.string(from: Date())
        switch (indexPath.row % 2 == 0) {
        case true:
            cell.likeButton.setImage(UIImage(named: "LikeActive"), for: .normal)
        case false:
            cell.likeButton.setImage(UIImage(named: "LikeNoActive"), for: .normal)
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photosName.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.identifier, for: indexPath)

        guard let imagesListCell = cell as? ImagesListCell else {
            print("Type casting error for ImagesListCell")
            return UITableViewCell()
        }

        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
}
