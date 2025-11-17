//
//  DIContainer.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

import UIKit

final class DIContainer {

    static let shared = DIContainer()

    private init() {}

    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var feedRepository: FeedRepositoryProtocol = FeedRepository(network: networkService)

    func makeFeedViewController() -> UIViewController {
        let vc = FeedViewController(repository: feedRepository)
        return vc
    }
}
