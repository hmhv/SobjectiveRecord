//
//  SobjectiveRecordDemo.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/06.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import Foundation
import CoreData

class Tweet: NSManagedObject {

    @NSManaged var createdAt: String?
    @NSManaged var createdDate: NSDate?
    @NSManaged var favoriteCount: NSNumber?
    @NSManaged var idStr: String
    @NSManaged var lang: String?
    @NSManaged var retweetCount: NSNumber?
    @NSManaged var source: String?
    @NSManaged var text: String?
    @NSManaged var timestampMs: NSDecimalNumber?
    @NSManaged var user: User?

}
