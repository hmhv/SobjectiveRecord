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

public let SRPersistentStoreCoordinatorWillMigratePersistentStore = "SRPersistentStoreCoordinatorWillMigratePersistentStore"
public let SRPersistentStoreCoordinatorDidMigratePersistentStore = "SRPersistentStoreCoordinatorDidMigratePersistentStore"

extension NSPersistentStoreCoordinator
{
    private struct Default {
        static var token: dispatch_once_t = 0
        static var storeCoordinator: NSPersistentStoreCoordinator? = nil
    }
    
    public class func setupDefaultStore(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSPersistentStoreCoordinator? {
        dispatch_once(&Default.token, {
            Default.storeCoordinator = NSPersistentStoreCoordinator.createStoreCoordinator(modelURL: modelURL, storeURL: storeURL, useInMemoryStore: useInMemoryStore)
        })
        return Default.storeCoordinator;
    }
    
    public class func needMigration(modelURL: NSURL? = nil, storeURL: NSURL? = nil) -> Bool {
        if let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL ?? NSURL.defaultModelURL()) {
            if let storeMetadata = self.metadataForPersistentStoreOfType(NSSQLiteStoreType, URL: storeURL ?? NSURL.defaultStoreURL(), error: nil) {
                if managedObjectModel.isConfiguration(nil, compatibleWithStoreMetadata: storeMetadata) == false {
                    return true
                }
            }
        }
        return false
    }

    class func createStoreCoordinator(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSPersistentStoreCoordinator {
        
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL ?? NSURL.defaultModelURL())
        
        let storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        
        var error: NSError? = nil
        var store = storeCoordinator.addPersistentStoreWithType((useInMemoryStore ? NSInMemoryStoreType : NSSQLiteStoreType), configuration: nil, URL: storeURL ?? NSURL.defaultStoreURL(), options: nil, error: &error)
        
        if store == nil && error != nil {
            println("ERROR WHILE CREATING PERSISTENT STORE \(error)")
            if error!.code == NSPersistentStoreIncompatibleVersionHashError {
                error = nil
                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
                
                NSNotificationCenter.defaultCenter().postNotificationName(SRPersistentStoreCoordinatorWillMigratePersistentStore, object: nil)
                
                store = storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL ?? NSURL.defaultStoreURL(), options: options, error: &error)
                
                NSNotificationCenter.defaultCenter().postNotificationName(SRPersistentStoreCoordinatorDidMigratePersistentStore, object: nil)
                
                if store == nil && error != nil {
                    println("ERROR WHILE MIGRATING PERSISTENT STORE \(error)")
                }
            }
        }
        
        return storeCoordinator
    }
}

