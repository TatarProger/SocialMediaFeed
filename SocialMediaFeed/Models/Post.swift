//
//  Post.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

// Models/Post.swift
import Foundation

struct PostDTO: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}


