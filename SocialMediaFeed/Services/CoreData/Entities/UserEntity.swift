//
//  UserEntity.swift
//  SocialMediaFeed
//
//  Created by Rishat Zakirov on 17.11.2025.
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject { }

extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var posts: NSSet?
}


