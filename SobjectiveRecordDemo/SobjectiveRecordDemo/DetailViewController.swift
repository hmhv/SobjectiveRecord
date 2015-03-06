//
//  DetailViewController.swift
//  HobjectiveRecordDemo-Swift
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit
import CoreData

protocol DetailViewControllerDelegate : class {
    func detailViewControllerFinished(sender: DetailViewController)
}

class DetailViewController : UIViewController {
    
    weak var delegate: DetailViewControllerDelegate? = nil
    
    var objectId: NSManagedObjectID? = nil
    var parentMoc: NSManagedObjectContext? = nil

    var moc: NSManagedObjectContext? = nil
    var tweet: Tweet? = nil

    
    @IBOutlet weak var screenNameTextField: UITextField!
    @IBOutlet weak var tweetTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.moc = self.parentMoc?.createChildContext()
        
        self.moc?.performBlock({ () -> Void in
            if let objectId = self.objectId {
                self.tweet = self.moc!.objectWithID(objectId) as? Tweet
            }
            else {
                self.tweet = Tweets.create(context: self.moc!)
                self.tweet?.idStr = "\(arc4random())"
                self.tweet?.user = Users.create(context: self.moc!)
                self.tweet?.user!.idStr = "\(arc4random())"
            }

            var screenName = self.tweet?.user?.screenName
            var tweetText = self.tweet?.text
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.screenNameTextField.text = screenName;
                self.tweetTextView.text = tweetText;
            })
        })
    }
    
    @IBAction func saveData(sender: UIBarButtonItem) {
        var screenName = self.screenNameTextField.text
        var tweetText = self.tweetTextView.text
        
        self.moc?.performBlock({ () -> Void in
            
            self.tweet?.user?.screenName = screenName
            self.tweet?.text = tweetText
            
            self.moc?.save()
            dispatch_async(dispatch_get_main_queue(), {
                if let delegate = self.delegate {
                    delegate.detailViewControllerFinished(self)
                }
            })
        })
    }
}
