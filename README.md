#  MKCacheStorage
Framework for saving objects persistent on disk. Extended by an dictionary which saves seen objects for faster delivery on duplicate requests.

## Roadmap
- [x] Saving & retrieving objects with NSCoding protocol on disk
- [x] Cache used objects in dictionary for usage on runtime
- [x] Include GCD for async requests and saving to don't block the main thread
- [x] Use singleton instance for usage outside the framework
- [x] Secondary indices for categorization of objects
- [ ] Own protocol for object serialization
- [ ] Own index class
- [ ] Reduce used disk space amount
- [ ] caching algorithm for most used object and for reducing memory usage
- [ ] auto save secondary indices on disk
- [x] Tests for every important action

## Performance

This table shows the peformance of the framework while putting in the shown number of objects and also recieve the whole amount back in serveral ways:

| function / # of objects | 100 | 1.000 | 10.000 | 50.000 |
| ------------------- |:------:|:-----:|:--------:|--------:|
| read direct from disk (*test case*) | ~0 | 0,343 | 3,3 s | 17,5 s |
| read from memory (*test case*) | ~0 | 0,00268 s | 0,0303 s | 0,181 s |
| read mixed async | 0,022 | 0,19 s | 1,85 s | 8.52 s |
| read labeld objects (n/2) | 0,020 | 0,15 s |  1,66 s | 8,2 s |
| | | | | |
| write objects without labels | 0,095 | 0,867 s | 7,78 s | 44,9 s |
| write objects with labels | 0,096 | 0,916 s | 10,5 s | 126 s |

This table shows the performance of the framework by 25.000 stored elements and the recieving of a different amount of objects in several ways:

| function / # of recieved objects from 25.000 | 1 | 10 | 100 | 1000 |
| -------------------------------------------------- |:-----:|:-----:|-------:|
| write objects initially |  | | | |
| read sequential | | | | |
| read by label | | | | |

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

