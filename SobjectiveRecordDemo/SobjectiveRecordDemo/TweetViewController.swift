//
//  TweetViewController.swift
//  HobjectiveRecordDemo-Swift
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import UIKit
import Accounts
import CoreData

class TweetViewController : UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, DetailViewControllerDelegate {
    
    var twitterAccount: ACAccount? = nil
    var use3Layer: Bool = false
    
    var twitterStream: TwitterStream? = nil
    var moc: NSManagedObjectContext? = nil
    var workMoc: NSManagedObjectContext? = nil
    var selectedObjectId: NSManagedObjectID? = nil
    var fetchedResertController: NSFetchedResultsController? = nil
    
    @IBOutlet weak var twitterStreamButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false;

        if self.use3Layer {
            self.moc = NSManagedObjectContext.defaultContext.createChildContextForMainQueue()
        }
        else {
            self.moc = NSManagedObjectContext.defaultContext
        }
        
        self.workMoc = self.moc?.createChildContext()
        
        self.indicator.startAnimating()
        
        self.moc?.performBlock({
            self.fetchedResertController = Tweets.createFetchedResultsController(order: "idStr", context: self.moc!)
            self.fetchedResertController?.delegate = self
            
            var error: NSError? = nil
            if self.fetchedResertController!.performFetch(&error) {
                self.reloadData()
            }
            else {
                println("\(error)")
            }
                
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stopTwitterStream()
        SDWebImageManager.sharedManager().cancelAll()
    }
    
    func reloadData() {
        if self.use3Layer {
            self.tableView.reloadData()
            self.indicator.stopAnimating()
            self.navigationItem.title = "\(self.fetchedResertController!.fetchedObjects!.count) tweets"
            println("reloadData : \(self.fetchedResertController!.fetchedObjects!.count) tweets")
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.indicator.stopAnimating()
                self.navigationItem.title = "\(self.fetchedResertController!.fetchedObjects!.count) tweets"
                println("reloadData : \(self.fetchedResertController!.fetchedObjects!.count) tweets")
            })
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "DetailSegue" {
            var vc = segue.destinationViewController as! DetailViewController
            vc.delegate = self;
            vc.objectId = self.selectedObjectId;
            vc.parentMoc = self.moc;

        }
    }

    @IBAction func addTweet() {
        self.selectedObjectId = nil
        self.performSegueWithIdentifier("DetailSegue", sender: self)
    }

    @IBAction func addRandomTweet() {
        var tweetCount = (arc4random() % 5) + 1
        
        self.moc?.performBlock({
            for var i: UInt32 = 0; i < tweetCount; i++ {
                var t = Tweets.create(attributes:
                    [
                        "idStr": "\(arc4random())",
                        "text": "text : \(arc4random())",
                    ]
                    , context: self.moc!)
                
                var u = Users.create(attributes:
                    [
                        "idStr": "\(arc4random())",
                        "screenName": "screenName : \(arc4random())"
                    ]
                    , context: self.moc!)
                t.user = u
            }
            self.moc?.save()
        })
    }

    @IBAction func switchTwitterStream() {
        if self.twitterStream != nil {
            self.stopTwitterStream()
        }
        else {
            self.startTwitterStream()
        }
    }
    
    func startTwitterStream() {
        if let tweetAccount = self.twitterAccount {
            self.twitterStream = TwitterStream()
            self.twitterStream!.twitterAccount = tweetAccount
            self.twitterStream!.moc = self.workMoc
            
            self.twitterStream!.start()
            self.twitterStreamButton.setTitle("Stop Twitter Stream", forState: UIControlState.Normal)
        }
        else {
            UIAlertView(title: "", message: "Twitter Account Error!!", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
        }
    }
    
    func stopTwitterStream() {
        if let twitterStream = self.twitterStream {
            twitterStream.stop()
            self.twitterStream = nil
        }
        self.twitterStreamButton.setTitle("Start Twitter Stream", forState: UIControlState.Normal)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = self.fetchedResertController?.fetchedObjects?.count {
            return count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as! UITableViewCell
        
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
        {
            cell.contentView.frame = cell.bounds;
            cell.contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        }

        self.configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        var t = self.fetchedResertController?.objectAtIndexPath(indexPath) as! Tweet
        
        if self.use3Layer {
            var upper = cell.viewWithTag(1) as! UILabel
            if let _screenName = t.user?.screenName {
                upper.text = "\(indexPath.row) - \(_screenName)"
            }
            else {
                upper.text = "\(indexPath.row) - no screen name"
            }

            var lower = cell.viewWithTag(2) as! UILabel
            lower.text = t.text
            
            var imageView = cell.viewWithTag(3) as! UIImageView
            if let _profileImageUrl = t.user?.profileImageUrl {
                imageView.sd_setImageWithURL(NSURL(string: _profileImageUrl), placeholderImage: nil)
            }
            else {
                imageView.image = nil
            }
        }
        else {
            t.performBlock() {
                var screenName : String = ""
                if let _screenName = t.user?.screenName {
                    screenName = "\(indexPath.row) - \(_screenName)"
                }
                else {
                    screenName = "\(indexPath.row) - no screen name"
                }
                var text = t.text
                var profileImageUrl = t.user?.profileImageUrl
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    var upper = cell.viewWithTag(1) as! UILabel
                    upper.text = screenName
                    
                    var lower = cell.viewWithTag(2) as! UILabel
                    lower.text = text
                    
                    var imageView = cell.viewWithTag(3) as! UIImageView
                    if let _profileImageUrl = profileImageUrl {
                        imageView.sd_setImageWithURL(NSURL(string: _profileImageUrl), placeholderImage: nil)
                    }
                    else {
                        imageView.image = nil
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        var t = self.fetchedResertController?.objectAtIndexPath(indexPath) as! Tweet
        self.selectedObjectId = t.objectID
        self.performSegueWithIdentifier("DetailSegue", sender: self)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            var t = self.fetchedResertController?.objectAtIndexPath(indexPath) as! Tweet
            t.performBlock({ () -> Void in
                if t.user?.tweets?.count == 1 {
                    t.user!.delete()
                }
                t.delete()
                t.save()
            })
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self .reloadData()
    }
    
    func detailViewControllerFinished(sender: DetailViewController) {
        self.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
}

