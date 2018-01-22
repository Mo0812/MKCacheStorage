#  MKCacheStorage
Framework for saving objects persistent on disk. Extended by an dictionary which saves seen objects for faster delivery on duplicate requests.

## Roadmap
- [x] Saving & retrieving objects with NSCoding protocol on disk
- [x] Cache used objects in dictionary for usage on runtime
- [x] Include GCD for async requests and saving to don't block the main thread
- [x] Use singleton instance for usage outside the framework
- [x] Secondary indices for categorization of objects
- [x] ~~Own protocol for object serialization~~ Using new Codable for object serialization
- [ ] Own index class
- [ ] Reduce used disk space amount
- [ ] caching algorithm for most used object and for reducing memory usage
- [ ] auto save secondary indices on disk
- [x] Tests for every important action

## Performance

This table shows the peformance of the framework while putting in the shown number of objects and also recieve the whole amount back in serveral ways:

| function / # of objects | 100 | 1.000 | 10.000 | 50.000 |
| ------------------- |:------:|:-----:|:--------:|--------:|
| read direct from disk (*test case*) | ~0 | 0,343 | 3,3 s | - |
| read from memory (*test case*) | ~0 | 0,00268 s | 0,0303 s | - |
| read mixed async | 0,028 | 0,279 s | 2,804 s | - |
| read labeld objects (n/2) | 0,072 s | 0,15 s |  0,861 s | - |
| | | | | |
| write objects without labels | 0,099 s | 0,914 s | 9,027 s | - |
| write objects with labels | 0,101 s | 0,922 s | 11,68 s | - |
| Test with plain objects with two basic attributes | | | | |
| used disk space | ~50MB | 3,9 MB | 39 MB | |
| used memory space | 400 KB | ~120 MB | ~700 MB | |

## Usage

### Init MKCacheStorage

You can initiate your MKCacheStorage instance via the singleton pattern with the `shared` variable shown in the code example.

```swift
let mkcstorage: MKCacheStorage = MKCacheStorage.shared
```

### Save objects

There `save` method stores objects in the framework, you can also give an array with labels for the object optionally:
- `save(object: NSObject, under identifier: String, result:@escaping (Bool) -> ())`
- `save(object:NSObject, under identifier: String, with labels: [String], result:@escaping (Bool) -> ())`

```swift
//saving objects
let id = "User1"
let object = MyObject()

mkcstorage.save(object: object, under: id, result: { success in
    //do stuff
})

//saving objects with given labels
let labels = ["friends, "contacts"]

mkcstorage.save(object: object, under: id, with: [labels], result: { success in
    //do stuff
})
```

### Retrieve objects

There are two methods for retrieving objects:
- `get(identifier: String, result:@escaping (NSObject?) -> ())`
- `get(label: String, result:@escaping ([NSObject]) -> ())`

Code example:

```swift
//get object by id
let id = "User1"

mkcstorage.get(identifier: id, result: { object in
    if let retrievedObj = object as? MyObject {
        //do stuff with object
    }
})

//get objects by id
let label = "contacts"

mkcstorage.get(label: label) { objects in
    //do stuff with objects
}
```

