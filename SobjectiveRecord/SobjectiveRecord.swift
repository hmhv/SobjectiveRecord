//
//  SobjectiveRecord.swift
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

public class SobjectiveRecord<T: NSManagedObject> {

    // MARK: - Creation / Deletion

    public class func create(attributes: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> T {
        var object = NSEntityDescription.insertNewObjectForEntityForName(T.entityName, inManagedObjectContext: context) as T
        if let _attributes = attributes as [String: AnyObject]? {
            object.update(_attributes)
        }
        return object
    }
    
    public class func deleteAll(context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) {
        self.delete(context: context)
    }

    public class func delete(condition: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) {
        let objects = self.find(condition: condition, context: context)
        for object in objects {
            context.deleteObject(object)
        }
    }
    
    // MARK: - Finders

    public class func all(order: String? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> [T] {
        return self.fetchWithCondition(order: order, context: context)
    }

    public class func find(condition: AnyObject? = nil, order: String? = nil, fetchLimit: Int = 0, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> [T] {
        return self.fetchWithCondition(condition: condition, order: order, fetchLimit: fetchLimit, context: context)
    }

    public class func first(condition: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> T? {
        return self.fetchWithCondition(condition: condition, fetchLimit: 0, context: context).first
    }

    public class func firstOrCreate(condition: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> T {
        var object = self.fetchWithCondition(condition: condition, fetchLimit: 0, context: context).first
        return object ?? self.create(attributes: condition, context: context)
    }

    // MARK: - Aggregation

    public class func count(condition: AnyObject? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> Int {
        let request = self.createFetchRequest(condition: condition, context: context)
        var error: NSError? = nil
        var result = context.countForFetchRequest(request, error: &error)
        if result == NSNotFound {
            println("ERROR WHILE EXECUTE FETCH REEQUEST \(error)");
            result = 0
        }
        return result
    }
    
    // MARK: - FetchedResultsController

    public class func createFetchedResultsController(condition: AnyObject? = nil, order: String? = nil, sectionNameKeyPath: String? = nil, context: NSManagedObjectContext = NSManagedObjectContext.defaultContext) -> NSFetchedResultsController {
        var request = self.createFetchRequest(condition: condition, order: order, context: context)
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }

    // MARK: - Private

    private class func createFetchRequest(condition: AnyObject? = nil, order: String? = nil, fetchLimit: Int = 0, context: NSManagedObjectContext) -> NSFetchRequest {
        var request = NSFetchRequest(entityName: T.entityName)
        
        if let _condition: AnyObject = condition {
            request.predicate = self.predicate(_condition, context: context)
        }
        
        if let _order = order {
            request.sortDescriptors = self.sortDescriptors(_order)
        }
        
        if fetchLimit > 0 {
            request.fetchLimit = fetchLimit
        }
        
        request.returnsObjectsAsFaults = T.returnsObjectsAsFaults
        
        request.relationshipKeyPathsForPrefetching = T.relationshipKeyPathsForPrefetching
        
        return request
    }
    
    private class func predicateFromDictionary(dict: [String: NSObject], context: NSManagedObjectContext) -> NSPredicate? {
        var subPredicates = [NSPredicate]()
        if let entity = NSEntityDescription.entityForName(T.entityName, inManagedObjectContext: context) {
            for (key, value) in dict {
                let localKey = T.keyForRemoteKey(key, context: context, entity: entity)
                if let _ = entity.attributesByName[localKey] {
                    if let predicate = NSPredicate(format: "%K = %@", key, value) {
                        subPredicates.append(predicate)
                    }
                }
            }
        }
        return subPredicates.count > 0 ? NSCompoundPredicate.andPredicateWithSubpredicates(subPredicates) : nil
    }

    private class func predicate(condition: AnyObject, context: NSManagedObjectContext) -> NSPredicate? {
        if let _condition = condition as? NSPredicate {
            return _condition
        }
        
        if let _condition = condition as? String {
            return NSPredicate(format: _condition)
        }
        
        if let _condition = condition as? [String: NSObject] {
            return self.predicateFromDictionary(_condition, context: context)
        }
        
        return nil
    }

    private class func sortDescriptor(sortKeyAndValue: String) -> NSSortDescriptor? {
        var keyAndValue = sortKeyAndValue.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        var key: String? = nil
        var isAscending = true
        
        for keyOrValue in keyAndValue {
            if keyOrValue.utf16Count == 0 {
                continue
            }
            if key == nil {
                key = keyOrValue
            }
            else if keyOrValue.uppercaseString.hasPrefix("D") {
                isAscending = false
                break
            }
        }
        
        if let _key = key {
            return NSSortDescriptor(key: _key, ascending: isAscending)
        }
        return nil
    }
    
    private class func sortDescriptors(order: String) -> [NSSortDescriptor]? {
        var orders = order.componentsSeparatedByString(",")
        var sortDescriptors = [NSSortDescriptor]()
        for sortKeyAndValue in orders {
            if let sortDescriptor = self.sortDescriptor(sortKeyAndValue) {
                sortDescriptors.append(sortDescriptor)
            }
        }
        
        return sortDescriptors.count > 0 ? sortDescriptors : nil
    }

    private class func fetchWithCondition(condition: AnyObject? = nil, order: String? = nil, fetchLimit: Int = 0, context: NSManagedObjectContext) -> [T] {
        var request = self.createFetchRequest(condition: condition, order: order, fetchLimit: fetchLimit, context: context)
        var error: NSError? = nil
        var result = context.executeFetchRequest(request, error: &error)
        if result == nil {
            println("ERROR WHILE EXECUTE FETCH REEQUEST \(error)");
            result = [T]()
        }
        return result! as [T]
    }

}