#  MKCacheStorage
Framework for saving objects persistent on disk. Extended by an dictionary which saves seen objects for faster delivery on duplicate requests.

## Roadmap
- [x] Saving & retrieving objects with NSCoding protocol on disk
- [x] Cache used objects in dictionary for usage on runtime
- [x] Include GCD for async requests and saving to don't block the main thread
- [x] Use singleton instance for usage outside the framework
- [ ] Secondary indices for categorization of objects
- [ ] Own protocol for object serialization
- [x] Tests for every important action

## Performance

| function/objects | 1.000 | 10.000 | 50.000 |
| ------------------- |:------:|:--------:|--------:|
| read direct from disk | 0,343 | 3,3 s | 17,5 s |
| read mixed async | 0,191 s | 1,96 s | 10,5 s |
| read from memory | 0,00268 s | 0,0303 s | 0,181 s |
