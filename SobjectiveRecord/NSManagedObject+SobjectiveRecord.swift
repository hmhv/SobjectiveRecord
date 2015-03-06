//
//  NSManagedObject+SobjectiveRecord.swift
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

extension NSManagedObject
{
    // MARK: - Instance Method
    
    func save() {
        self.managedObjectContext?.save()
    }
    
    func saveToParent() {
        self.managedObjectContext?.saveToParent()
    }
    
    func delete() {
        self.managedObjectContext?.deleteObject(self)
    }
    
    func update(propertis: [String: AnyObject]) -> Self {
        let attributes = self.entity.attributesByName
        let relationships = self.entity.relationshipsByName
        
        for (key, value) in propertis {
            let localKey = NSManagedObject.keyForRemoteKey(key, context: self.managedObjectContext!, entity: self.entity)
            
            if let attribute = attributes[localKey] as? NSAttributeDescription {
                self.setAttributeValue(value, key: localKey, attribute: attribute)
            }
            else if let relationship = relationships[localKey] as? NSRelationshipDescription {
                self.setRelationshipValue(value, key: localKey, relationship: relationship)
            }
        }
        return self
    }
    
    func performBlock(block: () -> Void) {
        self.managedObjectContext?.performBlock() {
            block()
        }
    }

    // MARK: - Naming

    class var entityName: String {
        let className = self.description().componentsSeparatedByString(".").last!
        return className
    }
    
    // MARK: - Fetching

    class var returnsObjectsAsFaults: Bool {
        return false
    }
    
    class var relationshipKeyPathsForPrefetching: [String]? {
        return nil
    }
    
    // MARK: - Mappings
    
    class var mappings: [String: String]? {
        return nil
    }
    
    class func useFindOrCreate() -> Bool {
        return false
    }
        
    class func keyForRemoteKey(remoteKey: String, context: NSManagedObjectContext, entity: NSEntityDescription) -> String {
        var localKey = self.keyMappingCache.objectForKey(remoteKey) as String?
        
        if localKey == nil {
            localKey = self.mappings?[remoteKey]
            
            if localKey == nil {
                let camelCasedProperty = remoteKey.toCamelCase()
                
                if let _ = entity.propertiesByName[camelCasedProperty] {
                    localKey = camelCasedProperty
                }
            }
            
            if localKey == nil {
                localKey = remoteKey
            }
            self.keyMappingCache.setObject(localKey!, forKey: remoteKey)
        }
        
        return localKey!
    }

    // MARK: - Private

    private func setAttributeValue(value: AnyObject, key: String, attribute: NSAttributeDescription) {
        if let _value = value as? NSNull {
            self.setNilValueForKey(key)
        }
        else {
            let attributeType = attribute.attributeType
            
            var convertedValue: AnyObject = value
            
            if attributeType == .StringAttributeType {
                
            }
            else if let _value = value as? String {
                if attributeType == .Integer16AttributeType || attributeType == .Integer32AttributeType || attributeType == .Integer64AttributeType {
                    convertedValue = NSNumber(integer: (_value as NSString).integerValue)
                }
                else if attributeType == .FloatAttributeType || attributeType == .DoubleAttributeType {
                    convertedValue = NSNumber(double: (_value as NSString).doubleValue)
                }
                else if attributeType == .BooleanAttributeType {
                    convertedValue = NSNumber(bool: (_value as NSString).boolValue)
                }
                else if attributeType == .DecimalAttributeType {
                    convertedValue = NSDecimalNumber(string: _value)
                }
                else if attributeType == .BinaryDataAttributeType {
                    convertedValue = (_value as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
                }
            }
            self.setValue(convertedValue, forKey: key)
        }
    }

    private func setRelationshipValue(value: AnyObject, key: String, relationship: NSRelationshipDescription) {
// FIXME: Relationship mapping not supported yet
//        if relationship.toMany {
//            
//            var valueArray = [AnyObject]()
//            
//            if let _value = value as? [String: AnyObject] {
//                var anyClass: AnyClass! = NSClassFromString(relationship.destinationEntity!.name!)
//                var object: AnyObject? = nil;
//                
//                if let useFindOrCreate: ()->Bool = anyClass.useFindOrCreate {
//                    if useFindOrCreate() {
//                    }
//                    else {
//                        
//                    }
//                }
//            }
//            else if let _value = value as? [[String: AnyObject]] {
//                
//            }
//            
//            if relationship.ordered {
//                var set = self.mutableOrderedSetValueForKey(key)
//                set.removeAllObjects()
//                set.addObjectsFromArray(valueArray)
//            }
//            else {
//                var set = self.mutableSetValueForKey(key)
//                set.removeAllObjects()
//                set.addObjectsFromArray(valueArray)
//            }
//        }
//        else {
//            
//        }
    }

    private class var keyMappingCache: NSCache {
        struct Singleton {
            static var s_keyMappingCache: NSCache = NSCache()
        }
        return Singleton.s_keyMappingCache
    }
}

extension String
{
    func toCamelCase() -> String {
        if self.utf16Count > 0 {
            var converted = self.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions(0))
            converted = converted.capitalizedString
            converted = converted.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions(0))
            let startIndex = converted.startIndex
            let endIndex = advance(startIndex, 1)
            let firstChar = converted.substringToIndex(endIndex)
            converted = converted.stringByReplacingCharactersInRange(Range<String.Index>(start: converted.startIndex, end: endIndex), withString: firstChar.lowercaseString)
            return converted
        }
        return self
    }
}


