//
//  NetworkService.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//
import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func fetchPosts(completion: @escaping (Result<[PostDTO], Error>) -> Void)
    func fetchUsers(completion: @escaping (Result<[UserDTO], Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {

    private let baseURL = "https://jsonplaceholder.typicode.com"

    func fetchPosts(completion: @escaping (Result<[PostDTO], Error>) -> Void) {
        let url = "\(baseURL)/posts"
        AF.request(url)
            .validate()
            .responseDecodable(of: [PostDTO].self) { response in
                switch response.result {
                case .success(let posts):
                    completion(.success(posts))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func fetchUsers(completion: @escaping (Result<[UserDTO], Error>) -> Void) {
        let url = "\(baseURL)/users"
        AF.request(url)
            .validate()
            .responseDecodable(of: [UserDTO].self) { response in
                switch response.result {
                case .success(let users):
                    completion(.success(users))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
