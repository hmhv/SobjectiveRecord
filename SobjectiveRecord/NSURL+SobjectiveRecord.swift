//
//  NSURL+SobjectiveRecord.swift
//
// Copyright (c) 2015 hmhv <http://hmhv.info/>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

extension NSURL
{
    class func defaultModelURL(modelName: String? = nil) -> NSURL {
        if let name = modelName {
            return NSBundle.mainBundle().URLForResource(name, withExtension: "momd")!
        }
        else {
            return NSBundle.mainBundle().URLForResource(appName(), withExtension: "momd")!
        }
    }
    
    class func defaultStoreURL(fileName: String? = nil) -> NSURL {
        if let name = fileName {
            return applicationDefaultDirectory().URLByAppendingPathComponent(name)
        }
        else {
            return applicationDefaultDirectory().URLByAppendingPathComponent(appName().stringByAppendingString(".sqlite"))
        }
    }
    
    private class func appName() -> String {
        var infoDictionary = NSBundle.mainBundle().infoDictionary!
        return infoDictionary["CFBundleName"] as String
    }
    
    private class func applicationDefaultDirectory() -> NSURL {
        var documentDirectory = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return documentDirectory.last as NSURL
    }
}
