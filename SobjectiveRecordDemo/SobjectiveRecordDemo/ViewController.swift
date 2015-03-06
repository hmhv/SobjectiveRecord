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
            var vc = segue.destinationViewController as TweetViewController
            vc.twitterAccount = self.twitterAccount
        }
        else {
            var vc = segue.destinationViewController as TweetViewController
            vc.twitterAccount = self.twitterAccount
            vc.use3Layer = true
        }
    }

    @IBAction func test() {
        var moc = NSManagedObjectContext.defaultContext
        
        moc.performBlock { () -> Void in
            println("Before Delete \(Tweets.count()) tweets of \(Users.count()) users")
            
            var tweets = Users.find(condition: ["lang": "ja"], fetchLimit: 5, order: "name d")
            
            println("Users \(tweets.count)")
            
            for u in tweets {
                println("User -> \(u.name)")
            }
            
        }

    }
    
}

