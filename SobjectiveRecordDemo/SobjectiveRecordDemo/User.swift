//
//  User.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var createdAt: String?
    @NSManaged var createdDate: NSDate?
    @NSManaged var favouritesCount: NSNumber?
    @NSManaged var followersCount: NSNumber?
    @NSManaged var friendsCount: NSNumber?
    @NSManaged var idStr: String
    @NSManaged var lang: String?
    @NSManaged var location: String?
    @NSManaged var name: String?
    @NSManaged var profileBackgroundColor: String?
    @NSManaged var profileBackgroundImageUrl: String?
    @NSManaged var profileImageUrl: String?
    @NSManaged var screenName: String?
    @NSManaged var statusesCount: NSNumber?
    @NSManaged var timeZone: String?
    @NSManaged var userDescription: String?
    @NSManaged var tweets: NSSet?

}
