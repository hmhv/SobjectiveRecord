//
//  Tweet+SobjectiveRecord.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/06.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import Foundation
import CoreData

extension Tweet
{
    override class var relationshipKeyPathsForPrefetching: [String]? {
        return ["user"]
    }
    
}