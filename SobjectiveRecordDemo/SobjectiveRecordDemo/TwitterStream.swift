//
//  TwitterStream.swift
//  SobjectiveRecordDemo
//
//  Created by 洪明勲 on 2015/03/05.
//  Copyright (c) 2015年 hmhv. All rights reserved.
//

import Foundation
import CoreData
import Accounts
import Social

class TwitterStream : NSObject, NSURLConnectionDataDelegate
{
    var twitterAccount: ACAccount? = nil
    var moc: NSManagedObjectContext? = nil
    var urlConnection: NSURLConnection? = nil
    var buffer : String? = nil
    
    func start() {
        var url = NSURL(string: "https://stream.twitter.com/1.1/statuses/sample.json")
        var request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, URL: url, parameters: ["delimited": "length"])
        request.account = self.twitterAccount
        self.urlConnection = NSURLConnection(request: request.preparedURLRequest(), delegate: self, startImmediately: false)
        if let urlConnection = self.urlConnection {
            urlConnection.setDelegateQueue(NSOperationQueue())
            urlConnection.start()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            println("Start Connection")
        }
    }
    
    func stop() {
        if let urlConnection = self.urlConnection {
            urlConnection.cancel()
            self.urlConnection = nil
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        println("Cancel Connection")
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        println("didFailWithError \(error)")
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        println("didReceiveResponse \(response)")
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        var response = NSString(data: data, encoding: NSUTF8StringEncoding)
        
        if let _response = response {
            for part in _response.componentsSeparatedByString("\r\n") as [String] {
                if let _ = part.toInt() {
                    if let buffer = self.buffer {
                        //println("buffer \n\n\(buffer)")
                        
                        if let tweetDictionary = NSJSONSerialization.JSONObjectWithData(buffer.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options:NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                            if tweetDictionary["id_str"] != nil {
                                if let _moc = self.moc {
                                    _moc.performBlock({ () -> Void in
                                        var t = Tweets.create(attributes: tweetDictionary, context: _moc)
                                        if let userDictionary = tweetDictionary["user"] as? [String: AnyObject] {
                                            var u = Users.create(attributes: userDictionary, context: _moc)
                                            t.user = u
                                        }
                                    })
                                }
                            }
                        }
                    }
                    self.buffer = ""
                }
                else {
                    self.buffer? += part
                }
            }
        }
        
        if let moc = self.moc {
            moc.performBlock({ () -> Void in
                moc.save()
            })
        }
    }
}
