//
//  AppDelegate.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit
import CoreData

typealias Users = SobjectiveRecord<User>
typealias Tweets = SobjectiveRecord<Tweet>

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        if NSPersistentStoreCoordinator.needMigration() {
            println("!! NEED Migration !!")
        }
        
        NSPersistentStoreCoordinator.setupDefaultStore()

        return true
    }

}

