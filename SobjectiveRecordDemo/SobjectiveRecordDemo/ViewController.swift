//
//  ViewController.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit
import CoreData
import Social
import Accounts

class ViewController: UIViewController {
    
    var accountStore = ACAccountStore()
    
    var twitterAccount: ACAccount?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let twitterAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        self.accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, error) -> Void in
            if granted {
                let twitterAccounts = self.accountStore.accountsWithAccountType(twitterAccountType)
                self.twitterAccount = twitterAccounts.first as? ACAccount
            }
            else {
                println("\(error)")
            }
        }
    }
    
    @IBAction func removeAllData() {
        var moc = NSManagedObjectContext.defaultContext
        
        moc.performBlock { () -> Void in
            println("Before Delete \(Tweets.count()) tweets of \(Users.count()) users")
            
            Tweets.deleteAll()
            Users.deleteAll()
            moc.save()
            
            println("After Delete \(Tweets.count()) tweets of \(Users.count()) users")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "TweetSegue" {
            var vc = segue.destinationViewController as! TweetViewController
            vc.twitterAccount = self.twitterAccount
        }
        else {
            var vc = segue.destinationViewController as! TweetViewController
            vc.twitterAccount = self.twitterAccount
            vc.use3Layer = true
        }
    }

    @IBAction func test() {
        
//        NSManagedObjectContext.defaultContext.performBlock {
//            // your code here
//        }
//        
//        var moc = NSManagedObjectContext.defaultContext.createChildContext()
//        moc.performBlock {
//            // your code here
//        }

        
//        NSManagedObjectContext.defaultContext.performBlock {
//            var t = Tweets.create()
//            t.text = "I am here"
//            t.save()
//            
//            t = Tweets.create(attributes: ["text" : "hello!!", "lang" : "en"])
//            t.delete()
//        }
//        
//        NSManagedObjectContext.defaultContext.performBlock {
//            Tweets.deleteAll()
//            NSManagedObjectContext.defaultContext.save()
//        }

//        NSManagedObjectContext.defaultContext.performBlock {
//            var tweets = Tweets.all()
//            
//            var tweetsInEnglish = Tweets.find(condition: "lang == 'en'")
//            
//            var hmhv = Users.first(condition: "screenName == 'hmhv'")
//            
//            var englishMen = Users.find(condition: ["lang" : "en", "timeZone" : "London"])
//            
//            var predicate = NSPredicate(format: "friendsCount > 100")
//            var manyFriendsUsers = Users.find(condition: predicate)
//        }

//        NSManagedObjectContext.defaultContext.performBlock {
//            var sortedUsers = Users.all(order: "name")
//            
//            var allUsers = Users.all(order: "screenName ASC, name DESC")
//            // or
//            var allUsers2 = Users.all(order: "screenName A, name D")
//            // or
//            var allUsers3 = Users.all(order: "screenName, name d")
//            
//            var manyFriendsUsers = Users.find(condition: "friendsCount > 100", order: "screenName DESC")
//            
//            var fiveEnglishUsers = Users.find(condition: "lang == 'en'", order: "screenName ASC", fetchLimit: 5)
//        }

//        NSManagedObjectContext.defaultContext.performBlock {
//            var allUserCount = Users.count()
//            
//            var englishUserCount = Users.count(condition: "lang == 'en'")
//        }

//        NSManagedObjectContext.defaultContext.performBlock {
//            
//            Users.batchUpdate(condition: "friendsCount > 10", propertiesToUpdate: ["friendsCount": 0])
//
//            // update all entities
//            Users.batchUpdate(propertiesToUpdate: ["friendsCount": 100])
//        }
        
//        NSManagedObjectContext.defaultContext.performBlock {
//            var frc = Users.createFetchedResultsController(order: "name")
//            frc.delegate = self
//            
//            var error: NSError? = nil
//            if frc.performFetch(&error) {
//                self.reloadData()
//            }
//        }

//        var childContext = NSManagedObjectContext.defaultContext.createChildContext()
//        
//        childContext.performBlock {
//            var john = Users.create(context: childContext)
//            john.name = "John"
//            john.save()
//            
//            var savedJohn = Users.first(condition: "name == 'John'", context: childContext)
//            
//            var manyFriendsUsers = Users.find(condition: "friendsCount > 100", order: "screenName DESC", context: childContext)
//            
//            var allUsers = Users.all(context: childContext)
//        }

        
//        var modelURL = NSURL.defaultModelURL(modelName: "model_name")
//        NSPersistentStoreCoordinator.setupDefaultStore(modelURL: modelURL)
//
//        // or
//        var storeURL = NSURL.defaultStoreURL(fileName: "file_name.sqlite")
//        NSPersistentStoreCoordinator.setupDefaultStore(storeURL: storeURL)

//        NSPersistentStoreCoordinator.setupDefaultStore(useInMemoryStore: true)
    }
    
}

