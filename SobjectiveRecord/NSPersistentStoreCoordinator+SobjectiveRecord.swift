//
//  NSPersistentStoreCoordinator+SobjectiveRecord.swift
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
import CoreData

extension NSPersistentStoreCoordinator
{
    private struct Default {
        static var token: dispatch_once_t = 0
        static var storeCoordinator: NSPersistentStoreCoordinator? = nil
    }
    
    class func setupDefaultStore(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSPersistentStoreCoordinator? {
        dispatch_once(&Default.token, {
            Default.storeCoordinator = NSPersistentStoreCoordinator.createStoreCoordinator(modelURL: modelURL, storeURL: storeURL, useInMemoryStore: useInMemoryStore)
        })
        return Default.storeCoordinator;
    }
    
    class func createStoreCoordinator(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSPersistentStoreCoordinator {
        
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL ?? NSURL.defaultModelURL())
        
        var storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        storeCoordinator.addPersistentStoreWithType((useInMemoryStore ? NSInMemoryStoreType : NSSQLiteStoreType), configuration: nil, URL: storeURL ?? NSURL.defaultStoreURL(), options: nil, error: nil)
        
        return storeCoordinator
    }
}
