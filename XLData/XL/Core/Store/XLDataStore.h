//
//  MenuTableViewController.m
//  XLData ( https://github.com/xmartlabs/XLData )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
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

#import "XLDataSectionStore.h"
#import <Foundation/Foundation.h>

@protocol XLDataStoreDelegate;

@interface XLDataStore : NSObject

@property id<XLDataStoreDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithDelegate:(id<XLDataStoreDelegate>)delegate;

- (BOOL)isEmpty;
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;
- (NSUInteger)totalNumberOfItems;
- (XLDataSectionStore *)sectionAtIndex:(NSUInteger)index;
- (XLDataSectionStore *)lastSection;
- (id)dataAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)indexOfSection:(XLDataSectionStore *)section;


-(void)addDataSection:(XLDataSectionStore *)dataSection;
-(void)addDataItem:(id)item;
-(void)addDataItems:(NSArray *)items;
-(void)removeDataSection:(XLDataSectionStore *)section;
-(void)removeDataItemAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)removeDataItem:(id)item;
-(BOOL)removeDataItemMatchingPredicate:(NSPredicate *)predicate;
-(BOOL)removeDataItemsMatchingPredicate:(NSPredicate *)predicate;


@end



@protocol XLDataStoreDelegate

typedef NS_ENUM(NSUInteger, XLDataStoreChangeType) {
    XLDataStoreChangeTypeInsert = 1,
    XLDataStoreChangeTypeDelete = 2,
    XLDataStoreChangeTypeMove = 3,
    XLDataStoreChangeTypeUpdate = 4
};

/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
	controller - controller instance that noticed the change on its fetched objects
	anObject - changed object
	indexPath - indexPath of changed object (nil for inserts)
	type - indicates if the change was an insert, delete, move, or update
	newIndexPath - the destination path for inserted or moved objects, nil otherwise
	
	Changes are reported with the following heuristics:
 
	On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported.
	The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
	The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys.
 */
@optional
- (void)dataStore:(XLDataStore *)dataStore didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(XLDataStoreChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
	controller - controller instance that noticed the change on its sections
	sectionInfo - changed section
	index - index of changed section
	type - indicates if the change was an insert or delete
 
	Changes on section info are reported before changes on fetchedObjects.
 */
@optional
- (void)dataStore:(XLDataStore *)dataStore didChangeSection:(XLDataSectionStore *)sectionStore atIndex:(NSUInteger)sectionIndex forChangeType:(XLDataStoreChangeType)type;

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
@optional
- (void)dataStoreWillChangeContent:(XLDataStore *)dataStore;

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
@optional
- (void)dataStoreDidChangeContent:(XLDataStore *)dataStore;


@end
