# SobjectiveRecord

[![Join the chat at https://gitter.im/hmhv/SobjectiveRecord](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/hmhv/SobjectiveRecord?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![SobjectiveRecord version](https://img.shields.io/cocoapods/v/SobjectiveRecord.svg?style=plastic)](http://cocoadocs.org/docsets/HobjectiveRecord) [![SobjectiveRecord platform](https://img.shields.io/cocoapods/p/SobjectiveRecord.svg?style=plastic)](http://cocoadocs.org/docsets/SobjectiveRecord) [![SobjectiveRecord license](https://img.shields.io/cocoapods/l/SobjectiveRecord.svg?style=plastic)](http://opensource.org/licenses/MIT)

SobjectiveRecord is Swift version of [HobjectiveRecord](https://github.com/hmhv/HobjectiveRecord).
**with Xcode 6.1.1**

HobjectiveRecord is inspired by [ObjectiveRecord](https://github.com/supermarin/ObjectiveRecord) and customized for background `NSManagedObjectContext`.

Before you use, i recommend you read these articles

- [a-real-guide-to-core-data-concurrency](http://quellish.tumblr.com/post/97430076027/a-real-guide-to-core-data-concurrency).
- [Multi-Context CoreData](http://www.cocoanetics.com/2012/07/multi-context-coredata/).

#### Usage

1. copy all files in folder `SobjectiveRecord` to your project.<br>
   or Install with [CocoaPods](http://cocoapods.org) `pod 'SobjectiveRecord'`

> You should use [CocoaPods](http://cocoapods.org) version 0.36 for Swift<br>
> for details read [Pod Authors Guide to CocoaPods Frameworks](http://blog.cocoapods.org/Pod-Authors-Guide-to-CocoaPods-Frameworks/)

#### Initialize

setup your store.

``` swift
import SobjectiveRecord // when useing CocoaPods

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    NSPersistentStoreCoordinator.setupDefaultStore()

	// youre code here
	
    return true
}
```

### Basic


your entities must have prefix (like projectName.entityName)

> ![entity_prefix.png](https://qiita-image-store.s3.amazonaws.com/0/25832/16d58c4f-b0a8-1240-3488-b9751ea21b1d.png "entity_prefix.png")


you can make your model's typealias for convenience

``` swift
// User, Tweet are NSManagedObject's subclass
typealias Users = SobjectiveRecord<User>
typealias Tweets = SobjectiveRecord<Tweet>

// so, it's same
var user = SobjectiveRecord<User>.create()
var user = Users.create()
```

use `performBlock`

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    // your code here
}

var moc = NSManagedObjectContext.defaultContext.createChildContext()
moc.performBlock {
    // your code here
}
```


#### Create / Save / Delete

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    var t = Tweets.create()
    t.text = "I am here"
    t.save()
    
    t = Tweets.create(attributes: ["text" : "hello!!", "lang" : "en"])
    t.delete()
}

NSManagedObjectContext.defaultContext.performBlock {
    Tweets.deleteAll()
    NSManagedObjectContext.defaultContext.save()
}
```

#### Finders

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    var tweets = Tweets.all()
    
    var tweetsInEnglish = Tweets.find(condition: "lang == 'en'")
    
    var hmhv = Users.first(condition: "screenName == 'hmhv'")
    
    var englishMen = Users.find(condition: ["lang" : "en", "timeZone" : "London"])
    
    var predicate = NSPredicate(format: "friendsCount > 100")
    var manyFriendsUsers = Users.find(condition: predicate)
}
```

#### Order and Limit

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    var sortedUsers = Users.all(order: "name")
    
    var allUsers = Users.all(order: "screenName ASC, name DESC")
    // or
    var allUsers2 = Users.all(order: "screenName A, name D")
    // or
    var allUsers3 = Users.all(order: "screenName, name d")
    
    var manyFriendsUsers = Users.find(condition: "friendsCount > 100", order: "screenName DESC")
    
    var fiveEnglishUsers = Users.find(condition: "lang == 'en'", order: "screenName ASC", fetchLimit: 5)
}
```

#### Aggregation

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    var allUserCount = Users.count()
    
    var englishUserCount = Users.count(condition: "lang == 'en'")
}
```

#### NSFetchedResultsController

``` swift
NSManagedObjectContext.defaultContext.performBlock {
    var frc = Users.createFetchedResultsController(order: "name")
    frc.delegate = self
    
    var error: NSError? = nil
    if frc.performFetch(&error) {
        self.reloadData()
    }
}
```

#### Custom ManagedObjectContext

``` swift
var childContext = NSManagedObjectContext.defaultContext.createChildContext()

childContext.performBlock {
    var john = Users.create()
    john.name = "John"
    john.save()
    
    var savedJohn = Users.first(condition: "name == 'John'", context: childContext)
    
    var manyFriendsUsers = Users.find(condition: "friendsCount > 100", order: "screenName DESC", context: childContext)
    
    var allUsers = Users.all(context: childContext)
}
```

#### Custom CoreData model or .sqlite database

If you've added the Core Data manually, you can change the custom model and database name.

``` swift
var modelURL = NSURL.defaultModelURL(modelName: "model_name")
NSPersistentStoreCoordinator.setupDefaultStore(modelURL: modelURL)

// or
var storeURL = NSURL.defaultStoreURL(fileName: "file_name.sqlite")
NSPersistentStoreCoordinator.setupDefaultStore(storeURL: storeURL)
```



#### Mapping

The most of the time, your JSON web service returns keys like `first_name`, `last_name`, etc. <br/>
Your Swift implementation has camelCased properties - `firstName`, `lastName`.<br/>

camel case is supported automatically - you don't have to do anything! Otherwise, if you have more complex mapping, here's how you do it:

**!! Date, Transformable Types and Relationships are not supported !!**

``` swift
// just override +mappings in your NSManagedObject subclass
extension User
{
    override class var mappings: [String: String]? {
        return ["description" : "userDescription"]
    }
}
// first_name => firstName is automatically handled
```

#### Testing

SobjectiveRecord supports CoreData's in-memory store. In any place, before your tests start running, it's enough to call

``` swift
NSPersistentStoreCoordinator.setupDefaultStore(useInMemoryStore: true)
```


## License

SobjectiveRecord is available under the MIT license. See the LICENSE file
for more information.
