#  MKCacheStorage
Framework for saving objects persistent on disk. Extended by an dictionary which saves seen objects for faster delivery on duplicate requests.

## Roadmap
- [x] Saving & retrieving objects with NSCoding protocol on disk
- [x] Cache used objects in dictionary for usage on runtime
- [x] Include GCD for async requests and saving to don't block the main thread
- [ ] Use singleton instance for usage outside the framework
- [ ] Secondary indices for categorization of objects
- [ ] Own protocol for object serialization
- [x] Tests for every important action
