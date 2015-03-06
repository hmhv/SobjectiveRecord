//
//  NSManagedObjectContext+SobjectiveRecoad.swift
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

extension NSManagedObjectContext
{
    private struct Default {
        static let context: NSManagedObjectContext = {
            let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
            context.persistentStoreCoordinator = NSPersistentStoreCoordinator.setupDefaultStore()
            return context
            }()
    }

    class var defaultContext: NSManagedObjectContext {
        get {
            return Default.context;
        }
    }
    
    func createChildContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.parentContext = self
        return context
    }
    
    func createChildContextForMainQueue() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = self
        return context
    }
    
    class func save() {
        Default.context.performBlock {
            Default.context.save()
        }
    }
    
    class func saveToParent() {
        Default.context.performBlock {
            Default.context.saveToParent()
        }
    }

    func save() {
        if self.hasChanges {
            var error: NSError? = nil;
            let saved = self.save(&error)
            if saved == false {
                println("ERROR WHILE SAVE \(error)")
            }
            else if let parentContext = self.parentContext {
                parentContext.performBlock {
                    parentContext.save()
                }
            }
        }
    }
    
    func saveToParent() {
        if self.hasChanges && self.parentContext != nil {
            var error: NSError? = nil;
            let saved = self.save(&error)
            if saved == false {
                println("ERROR WHILE SAVE \(error)")
            }
        }
    }
    
    func performBlockSynchronously(block: () -> Void) {
        var group = dispatch_group_create();
        dispatch_group_enter(group);
        self.performBlock {
            block()
            dispatch_group_leave(group);
        }
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    
    // Do not use if you don't know what you do.
    func createContext(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator.createStoreCoordinator(modelURL: modelURL, storeURL: storeURL, useInMemoryStore: useInMemoryStore)
        return context
    }
    
    // Do not use if you don't know what you do.
    func createContextForMainQueue(modelURL: NSURL? = nil, storeURL: NSURL? = nil, useInMemoryStore: Bool = false) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = NSPersistentStoreCoordinator.createStoreCoordinator(modelURL: modelURL, storeURL: storeURL, useInMemoryStore: useInMemoryStore)
        return context
    }

}

