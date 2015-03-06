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
        if let _urlConnection = self.urlConnection {
            _urlConnection.setDelegateQueue(NSOperationQueue())
            _urlConnection.start()
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            println("Start Connection")
        }
    }
    
    func stop() {
        if let _urlConnection = self.urlConnection {
            _urlConnection.cancel()
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
                    if let _buffer = self.buffer {
                        //println("_buffer \n\n\(_buffer)")
                        
                        if let _tweetDictionary = NSJSONSerialization.JSONObjectWithData(_buffer.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!, options:NSJSONReadingOptions.AllowFragments, error: nil) as? [String: AnyObject] {
                            if _tweetDictionary["id_str"] != nil {
                                if let _moc = self.moc {
                                    _moc.performBlock({ () -> Void in
                                        var t = Tweets.create(attributes: _tweetDictionary, context: _moc)
                                        if let _userDictionary = _tweetDictionary["user"] as? [String: AnyObject] {
                                            var u = Users.create(attributes: _userDictionary, context: _moc)
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
        
        if let _moc = self.moc {
            _moc.performBlock({ () -> Void in
                _moc.saveToStore()
            })
        }
    }
}
