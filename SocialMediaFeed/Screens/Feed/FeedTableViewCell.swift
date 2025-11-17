//
//  FeedTableViewCell.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

import UIKit
import Kingfisher

final class FeedTableViewCell: UITableViewCell {

    static let reuseId = "FeedTableViewCell"

    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.layer.cornerRadius = 20
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()

    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(likeButton)

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 40),
            avatarImageView.heightAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -8),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.topAnchor),

            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            likeButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            bodyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }

    // MARK: - Configure

    func configure(with post: FeedPost) {
        nameLabel.text = post.userName
        titleLabel.text = post.title
        bodyLabel.text = post.body
        updateLikeButton(isLiked: post.isLiked)
        loadAvatar(userId: post.userId)
    }

    func updateLikeButton(isLiked: Bool) {
        let title = isLiked ? "♥️" : "♡"
        likeButton.setTitle(title, for: .normal)
    }

    // MARK: - Kingfisher avatar loader

    private func loadAvatar(userId: Int) {
        let urlString = "https://picsum.photos/seed/\(userId)/80"
        guard let url = URL(string: urlString) else { return }

        avatarImageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.crop.circle"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}
