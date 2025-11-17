//
//  PostEntity.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

import Foundation
import CoreData

@objc(PostEntity)
public class PostEntity: NSManagedObject { }

extension PostEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PostEntity> {
        return NSFetchRequest<PostEntity>(entityName: "PostEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var userId: Int64
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var isLiked: Bool
    @NSManaged public var user: UserEntity?
}
