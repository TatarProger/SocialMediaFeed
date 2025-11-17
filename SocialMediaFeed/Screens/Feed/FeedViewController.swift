//
//  FeedViewController.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

import UIKit

final class FeedViewController: UIViewController {

    private let repository: FeedRepositoryProtocol

    private var state: FeedState = .idle {
        didSet { updateUIForState() }
    }

    private var posts: [FeedPost] = []
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Init

    init(repository: FeedRepositoryProtocol) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
        self.title = "Лента"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFeed(forceRefresh: false)
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        loadFeed(forceRefresh: true)
    }

    // MARK: - Data loading

    private func loadFeed(forceRefresh: Bool) {
        state = .loading

        repository.loadFeed(forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }

            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self?.posts = posts
                    self?.state = .loaded
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.state = .error(error.localizedDescription)
                }
            }
        }
    }

    private func updateUIForState() {
        switch state {
        case .idle:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        case .loaded:
            activityIndicator.stopAnimating()
        case .error(let message):
            activityIndicator.stopAnimating()
            showError(message: message)
        }
    }

    private func showError(message: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func toggleLike(at indexPath: IndexPath) {
        let post = posts[indexPath.row]
        repository.toggleLike(postId: post.id) { [weak self] result in
            switch result {
            case .success(let updatedPost):
                DispatchQueue.main.async {
                    self?.posts[indexPath.row] = updatedPost
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? FeedTableViewCell {
                        cell.updateLikeButton(isLiked: updatedPost.isLiked)
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showError(message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        posts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FeedTableViewCell.reuseId,
            for: indexPath
        ) as? FeedTableViewCell else {
            return UITableViewCell()
        }

        let post = posts[indexPath.row]
        cell.configure(with: post)
        cell.likeButton.tag = indexPath.row
        cell.likeButton.removeTarget(nil, action: nil, for: .allEvents)
        cell.likeButton.addTarget(self,
                                  action: #selector(likeButtonTapped(_:)),
                                  for: .touchUpInside)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FeedViewController: UITableViewDelegate {

    @objc private func likeButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: 0)
        toggleLike(at: indexPath)
    }
}


