//
//  FeedRepository.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//
import Foundation
import CoreData

struct FeedPost {
    let id: Int
    let userName: String
    let title: String
    let body: String
    let isLiked: Bool
    let userId: Int
}

protocol FeedRepositoryProtocol {
    func loadFeed(forceRefresh: Bool,
                  completion: @escaping (Result<[FeedPost], Error>) -> Void)

    func toggleLike(postId: Int, completion: @escaping (Result<FeedPost, Error>) -> Void)
}

final class FeedRepository: FeedRepositoryProtocol {

    private let network: NetworkServiceProtocol
    private let coreData: CoreDataStack

    init(network: NetworkServiceProtocol, coreData: CoreDataStack = .shared) {
        self.network = network
        self.coreData = coreData
    }

    func loadFeed(forceRefresh: Bool,
                  completion: @escaping (Result<[FeedPost], Error>) -> Void) {

        if !forceRefresh {
            let localPosts = fetchFeedFromCoreData()
            if !localPosts.isEmpty {
                completion(.success(localPosts))
            }
        }

        network.fetchUsers { [weak self] usersResult in
            guard let self = self else { return }

            switch usersResult {
            case .failure(let error):
                let localPosts = self.fetchFeedFromCoreData()
                if !localPosts.isEmpty {
                    completion(.success(localPosts))
                } else {
                    completion(.failure(error))
                }
            case .success(let users):
                self.network.fetchPosts { postsResult in
                    switch postsResult {
                    case .failure(let error):
                        let localPosts = self.fetchFeedFromCoreData()
                        if !localPosts.isEmpty {
                            completion(.success(localPosts))
                        } else {
                            completion(.failure(error))
                        }

                    case .success(let posts):
                        self.saveToCoreData(posts: posts, users: users)
                        let feed = self.fetchFeedFromCoreData()
                        completion(.success(feed))
                    }
                }
            }
        }
    }

    func toggleLike(postId: Int, completion: @escaping (Result<FeedPost, Error>) -> Void) {
        let context = coreData.context
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", postId)

        do {
            if let entity = try context.fetch(request).first {
                entity.isLiked.toggle()
                try context.save()

                if let user = entity.user {
                    let post = FeedPost(
                        id: Int(entity.id),
                        userName: user.name ?? "",
                        title: entity.title ?? "",
                        body: entity.body ?? "",
                        isLiked: entity.isLiked,
                        userId: Int(entity.userId)
                    )
                    completion(.success(post))
                } else {
                    throw NSError(domain: "FeedRepository",
                                  code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "User not found"])
                }
            } else {
                throw NSError(domain: "FeedRepository",
                              code: 0,
                              userInfo: [NSLocalizedDescriptionKey: "Post not found"])
            }
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Private

    private func saveToCoreData(posts: [PostDTO], users: [UserDTO]) {
        let context = coreData.context

        let fetchExisting: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        var likedById: [Int64: Bool] = [:]
        if let existingPosts = try? context.fetch(fetchExisting) {
            for post in existingPosts {
                likedById[post.id] = post.isLiked
            }
        }

        let fetchPosts: NSFetchRequest<NSFetchRequestResult> = PostEntity.fetchRequest()
        let deletePostsRequest = NSBatchDeleteRequest(fetchRequest: fetchPosts)

        let fetchUsers: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteUsersRequest = NSBatchDeleteRequest(fetchRequest: fetchUsers)

        do {
            try context.execute(deletePostsRequest)
            try context.execute(deleteUsersRequest)

            var userMap: [Int: UserEntity] = [:]
            for userDTO in users {
                let user = UserEntity(context: context)
                user.id = Int64(userDTO.id)
                user.name = userDTO.name
                userMap[userDTO.id] = user
            }

            for postDTO in posts {
                let post = PostEntity(context: context)
                post.id = Int64(postDTO.id)
                post.userId = Int64(postDTO.userId)
                post.title = postDTO.title
                post.body = postDTO.body

                let key = Int64(postDTO.id)
                post.isLiked = likedById[key] ?? false   

                post.user = userMap[postDTO.userId]
            }

            try context.save()
        } catch {
            print("CoreData saveToCoreData error: \(error)")
        }
    }


    private func fetchFeedFromCoreData() -> [FeedPost] {
        let context = coreData.context
        let request: NSFetchRequest<PostEntity> = PostEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                guard let user = entity.user else { return nil }
                return FeedPost(
                    id: Int(entity.id),
                    userName: user.name ?? "",
                    title: entity.title ?? "",
                    body: entity.body ?? "",
                    isLiked: entity.isLiked,
                    userId: Int(entity.userId)
                )
            }
        } catch {
            print("CoreData fetchFeedFromCoreData error: \(error)")
            return []
        }
    }
}
