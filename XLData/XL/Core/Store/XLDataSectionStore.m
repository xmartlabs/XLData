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

@import UIKit;
#import "XLDataStore.h"
#import "XLDataSectionStore.h"

@interface XLDataSectionStore()

@property NSMutableArray * dataRows;
@property NSString * title;

@end

@implementation XLDataSectionStore

@synthesize title = _title;


- (instancetype)init
{
    return [self initWithTitle:nil];
}

- (instancetype)initWithTitle:(NSString *)title
{
    self = [super init];
    if (self) {
        _title = title;
        _dataRows = [[NSMutableArray alloc] init];
        [self addObserver:self forKeyPath:@"dataRows" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:0];
    }
    return self;
}

+ (instancetype)dataSectionStore
{
    return [self dataSectionStoreWithTitle:nil];
}

+ (instancetype)dataSectionStoreWithTitle:(NSString *)title
{
    return [[self alloc] initWithTitle:title];
}

- (NSUInteger)numberOfItems
{
    return self.dataRows.count;
}

- (NSString *)title
{
    return _title;
}

-(void)setTitle:(NSString *)title
{
    _title = title;
}

-(id)dataAtIndex:(NSUInteger)index
{
    return [self.dataRows objectAtIndex:index];
}

-(void)addDataItem:(id)item
{
    [self insertObject:item inDataRowsAtIndex:[self countOfDataRows]];
}

-(void)addDataItems:(NSArray *)items
{
    [self addDataItems:items fromIndex:[self countOfDataRows]];
}

-(void)addDataItems:(NSArray *)items fromIndex:(NSUInteger)fromIndex
{
    if (fromIndex >=  self.dataRows.count){
        [self insertDataRows:items atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.dataRows.count, items.count)]];
    }
    else {  // fromIndex < self.dataRows.count
        NSUInteger newCountOfItems  = fromIndex + items.count;
        NSUInteger countOfReplacedObjects = MIN(items.count, self.dataRows.count - fromIndex);
        NSIndexSet * indexSetToReplace = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(fromIndex, countOfReplacedObjects)];
        [self replaceDataRowsAtIndexes:indexSetToReplace withDataRows:[items objectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, countOfReplacedObjects)]]];
        if (countOfReplacedObjects < items.count){
            NSIndexSet * indexSetNotReplacedItems = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(countOfReplacedObjects, items.count - countOfReplacedObjects)];
            [self insertDataRows:[items objectsAtIndexes:indexSetNotReplacedItems] atIndexes:indexSetNotReplacedItems];
        }
        [self removeDataItemsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newCountOfItems, self.dataRows.count - newCountOfItems)]];
    }
}

-(void)removeDataItemAtIndex:(NSUInteger)indexPath
{
    [self removeDataItemsAtIndexes:[NSIndexSet indexSetWithIndex:indexPath]];
}

-(BOOL)removeDataItem:(id)item
{
    NSUInteger index = [self.dataRows indexOfObject:item];
    if (index != NSNotFound){
        [self removeDataItemAtIndex:index];
        return YES;
    }
    return NO;
}

- (BOOL)removeDataItemMatchingPredicate:(NSPredicate *)predicate
{
    BOOL __block result = NO;
    [[self.dataRows copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @try {
            result = [predicate evaluateWithObject:obj substitutionVariables:nil];
            if (result){
                [self removeDataItemAtIndex:idx];
                *stop = YES;
            }
        }
        @catch (NSException *exception) {}
    }];
    return result;
}

- (BOOL)removeDataItemsMatchingPredicate:(NSPredicate *)predicate
{
    BOOL __block result = NO;
    [[self.dataRows copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        @try {
            BOOL evalResult = [predicate evaluateWithObject:obj substitutionVariables:nil];
            if (evalResult){
                [self removeDataItemAtIndex:idx];
            }
            result = result || evalResult;
        }
        @catch (NSException *exception) {}
    }];
    return result;
}

-(void)removeDataItemsAtIndexes:(NSIndexSet *)indexSet{
    [self removeDataRowsAtIndexes:indexSet];
}


-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"dataRows"];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.dataStore.delegate) return;
    if ([keyPath isEqualToString:@"dataRows"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]){
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            if (indexSet.firstIndex != NSNotFound){
                NSArray * newRows = [change objectForKey:NSKeyValueChangeNewKey];
                [self.dataStore.delegate dataStoreWillChangeContent:self.dataStore];
                NSUInteger sectionIndex = [self.dataStore indexOfSection:self];
                NSAssert(sectionIndex != NSNotFound, @"sectionIndex must not be equal to NSNotFound");
                NSUInteger index __block = 0;
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [self.dataStore.delegate dataStore:self.dataStore didChangeObject:newRows[index++]
                                           atIndexPath:nil forChangeType:XLDataStoreChangeTypeInsert
                                          newIndexPath:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]];
                }];
                [self.dataStore.delegate dataStoreDidChangeContent:self.dataStore];
            }
        }
        else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]){
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            if (indexSet.firstIndex != NSNotFound){
                NSArray * oldRows = [change objectForKey:NSKeyValueChangeOldKey];
                [self.dataStore.delegate dataStoreWillChangeContent:self.dataStore];
                NSUInteger sectionIndex = [self.dataStore indexOfSection:self];
                NSAssert(sectionIndex != NSNotFound, @"sectionIndex must not be equal to NSNotFound");
                NSUInteger index __block = 0;
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [self.dataStore.delegate dataStore:self.dataStore
                                       didChangeObject:oldRows[index++]
                                           atIndexPath:[NSIndexPath indexPathForRow:idx inSection:sectionIndex]
                                         forChangeType:XLDataStoreChangeTypeDelete
                                          newIndexPath:nil];
                }];
                [self.dataStore.delegate dataStoreDidChangeContent:self.dataStore];
            }
        }
        else{
            NSAssert(true, @"");
        }
    }
}

#pragma mark - KVC

-(NSUInteger)countOfDataRows
{
    return self.dataRows.count;
}

- (id)objectInDataRowsAtIndex:(NSUInteger)index
{
    return [self.dataRows objectAtIndex:index];
}

- (NSArray *)dataRowsAtIndexes:(NSIndexSet *)indexes
{
    return [self.dataRows objectsAtIndexes:indexes];
}

-(void)insertObject:(id)object inDataRowsAtIndex:(NSUInteger)index
{
    [self.dataRows insertObject:object atIndex:index];
}

-(void)insertDataRows:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.dataRows insertObjects:array atIndexes:indexes];
}
     
-(void)removeDataRowsAtIndexes:(NSIndexSet *)indexes
{
    [self.dataRows removeObjectsAtIndexes:indexes];
}

- (void)removeObjectFromDataRowsAtIndex:(NSUInteger)index
{
    [self.dataRows removeObjectAtIndex:index];
}

-(void)replaceObjectInDataRowsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self.dataRows replaceObjectAtIndex:index withObject:object];
}

-(void)replaceDataRowsAtIndexes:(NSIndexSet *)indexes withDataRows:(NSArray *)array
{
    [self.dataRows replaceObjectsAtIndexes:indexes withObjects:array];
}


@end
