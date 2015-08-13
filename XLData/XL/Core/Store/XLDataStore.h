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


/**
 *  This is a data store abstraction, we can add sections and items to its sections. Every change we make on the DataStore will be notified throught the delegate property (id<XLDataStoreDelegate> delegate).
 */
@interface XLDataStore : NSObject

@property id<XLDataStoreDelegate> delegate;

- (instancetype)init;
- (instancetype)initWithDelegate:(id<XLDataStoreDelegate>)delegate;

/**
 *  Returns YES if the dataStore has no sections, otherwise NO.
 *
 *  @return YES if the dataStore has no sections
 */
- (BOOL)isEmpty;

/**
 *  Returns the number of sections contained in the dataStore.
 *
 *  @return the number of sections in the dataStore.
 */
- (NSUInteger)numberOfSections;

/**
 *  Returns the number of items contained in the section placed at section index.
 *
 *  @param section specify the index of the section
 *
 *  @return Returns the number of items contained in the section
 */
- (NSUInteger)numberOfItemsInSection:(NSUInteger)section;

/**
 *  Returns the count of items within the data store.
 *
 *  @return Total number of items, it's the sum of all section items.
 */
- (NSUInteger)totalNumberOfItems;

/**
 *  Returns the section located at the specified index.
 *  
 *  If index is beyond the end of the dataStore (that is, if index is greater than or equal to the value returned by numberOfSections), an NSRangeException is raised.
 *  @param index An index within the bounds of the dataStore.
 *
 *  @return XLDataStoreSection instance.
 */
- (XLDataSectionStore *)sectionAtIndex:(NSUInteger)index;

/**
 *  It returns the sections located at the last index, if the dataStore hasn't got any section, it creates one empty section, adds it to the dataStore and return it.
 *
 *  @return section located at the last index.
 */
- (XLDataSectionStore *)lastSection;

/**
 *  Returns the object located at indexPath, if there is no object located at indexPath an NSRangeException is raised.
 *
 *  @param indexPath An indexPath that specify a section value for lookup the sectionStore and a row for lookup the object (data) within the sectionStore.
 *
 *  @return data located at indexPath.
 */
- (id)dataAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns the index whose corresponding section is equal to a given section.
 *
 *  @param section a XLDataSection object.
 *
 *  @return The index whose corresponding section is equal to section. If none of the dataSections in the dataStore is equal to section, returns NSNotFound.
 */
- (NSUInteger)indexOfSection:(XLDataSectionStore *)section;

/**
 *  Inserts the given dataSection to the end of dataStore sections collection.
 *
 *  @param dataSection
 */
-(void)addDataSection:(XLDataSectionStore *)dataSection;

/**
 *  Inserts the given dataSection into the dataSection collection at a given index.
 *
 *  @param dataSection dataSection to insert
 *  @param index       The index in the dataSection's collection at which to insert the dataSection. This value must not be greater than the count of sections in the dataStore.
 *                     Important
 *                     Raises an NSRangeException if index is greater than the number of sections in the dataStore.
 */
-(void)addDataSection:(XLDataSectionStore *)dataSection atIndex:(NSUInteger)index;

/**
 *  Insert dataSection before beforeSection, if beforeSection is not present in the dataStore the dataSection is inserted at the end of the dataStore.
 *
 *  @param dataSection   section to insert.
 *  @param beforeSection section used to determine the proper location to insert dataSection.
 */
-(void)addDataSection:(XLDataSectionStore *)dataSection beforeSection:(XLDataSectionStore *)beforeSection;

/**
 *  Insert dataSection after afterSection, if afterSection is not present in the dataStore the dataSection is inserted at the end of the dataStore.
 *
 *  @param dataSection  section to insert.
 *  @param afterSection section used to determine the proper location to insert dataSection.
 */
-(void)addDataSection:(XLDataSectionStore *)dataSection afterSection:(XLDataSectionStore *)afterSection;

/**
 *  Insert the data item into the last section of the dataStore
 *
 *  @param item An item to insert.
 */
-(void)addDataItem:(id)item;

/**
 *  Insert items at the end of the last section.
 *
 *  @param items items to be inserted.
 */
-(void)addDataItems:(NSArray *)items;

/**
 *  Removes section from the dataStore.
 *
 *  @param section dataSection to be removed from dataStore.
 */
-(void)removeDataSection:(XLDataSectionStore *)section;

/**
 *  Removes the data item located at specific indexPath
 *
 *  @param indexPath The indexPath of the data item to remove
 */
-(void)removeDataItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Removes item from the dataStore.
 *
 *  @param item data item to remove.
 *
 *  @return YES if the item is removed, otherwise NO.
 */
-(BOOL)removeDataItem:(id)item;

/**
 *  Removes the data item that matches the predicate.
 *
 *  @param predicate A predicate expression used to get the item that should be removed.
 *
 *  @return YES if the item is removed, otherwise NO.
 */
-(BOOL)removeDataItemMatchingPredicate:(NSPredicate *)predicate;

/**
 *  Removes the data items that match the predicate.
 *
 *  @param predicate A predicate expression used to get the items that should be removed.
 *
 *  @return YES if at least one item was removed, otherwise NO.
 */
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
