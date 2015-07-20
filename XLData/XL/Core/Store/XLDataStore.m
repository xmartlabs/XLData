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
#import "XLDataStore.h"
@import UIKit;

@class XLDataStore;

@interface XLDataStore()

@property NSMutableArray * dataSections;

@end

@implementation XLDataStore

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDelegate:(id<XLDataStoreDelegate>)delegate
{
    self = [self init];
    if (self) {
        _dataSections = [[NSMutableArray alloc] init];
        _delegate = delegate;
        [self addObserver:self forKeyPath:@"dataSections" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:0];
    }
    return self;
}

-(BOOL)isEmpty
{
    return self.dataSections.count == 0;
}

- (NSUInteger)numberOfSections
{
    return self.dataSections.count;
}

- (NSUInteger)numberOfItemsInSection:(NSUInteger)section
{
    return [[self sectionAtIndex:section] numberOfItems];
}

-(NSUInteger)totalNumberOfItems
{
    NSUInteger result __block = 0;
    [self.dataSections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result += [(XLDataSectionStore *)obj numberOfItems];
    }];
    return result;
}

- (XLDataSectionStore *)sectionAtIndex:(NSUInteger)index
{
    return [self.dataSections objectAtIndex:index];
}

- (XLDataSectionStore *)lastSection
{
    if ([self countOfDataSections] == 0){
        XLDataSectionStore * dataSection = [[XLDataSectionStore alloc] init];
        [self addDataSection:dataSection];
    }
    return [self objectInDataSectionsAtIndex:([self countOfDataSections] - 1)];
}

- (id)dataAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self sectionAtIndex:indexPath.section] dataAtIndex:indexPath.row];
}


-(void)addDataSection:(XLDataSectionStore *)dataSection
{
    [self insertObject:dataSection inDataSectionsAtIndex:[self countOfDataSections]];
}

-(void)addDataSection:(XLDataSectionStore *)dataSection atIndex:(NSUInteger)index
{
    [self insertObject:dataSection inDataSectionsAtIndex:index];
}

-(void)addDataSection:(XLDataSectionStore *)dataSection beforeSection:(XLDataSectionStore *)beforeSection
{
    NSUInteger index;
    if ((index = [self indexOfSection:beforeSection]) != NSNotFound) {
        [self insertObject:dataSection inDataSectionsAtIndex:index];
    }
    else{
        // if beforeSection does not exist we insert at the end.
        [self addDataSection:dataSection];
    }
}

-(void)addDataSection:(XLDataSectionStore *)dataSection afterSection:(XLDataSectionStore *)afterSection
{
    NSUInteger index;
    if ((index = [self indexOfSection:afterSection]) != NSNotFound) {
        [self insertObject:dataSection inDataSectionsAtIndex:index+1];
    }
    else{
        // if afterSection does not exist we insert at the end.
        [self addDataSection:dataSection];
    }
}

-(void)addDataItem:(id)item
{
    [[self lastSection] addDataItem:item];
}

-(void)addDataItems:(NSArray *)items
{
    [[self lastSection] addDataItems:items];
}

-(NSUInteger)indexOfSection:(XLDataSectionStore *)section
{
    return [self.dataSections indexOfObject:section];
}

-(void)removeDataSectionAtIndex:(NSUInteger)index
{
    if (self.dataSections.count > index){
        [self removeObjectFromDataSectionsAtIndex:index];
    }
}


-(void)removeDataSection:(XLDataSectionStore *)dataSection
{
    NSUInteger index = NSNotFound;
    if ((index = [self.dataSections indexOfObject:dataSection]) != NSNotFound){
        [self removeDataSectionAtIndex:index];
    }
}

-(void)removeDataItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSections.count > indexPath.section){
        XLDataSectionStore *dataSection = [self.dataSections objectAtIndex:indexPath.section];
        [dataSection removeDataItemAtIndex:indexPath.row];
    }
}

-(BOOL)removeDataItem:(id)item
{
    for (XLDataSectionStore * dataSection in self.dataSections) {
        BOOL removed = [dataSection removeDataItem:item];
        if (removed){
            return YES;
        }
    }
    return NO;
}

-(BOOL)removeDataItemMatchingPredicate:(NSPredicate *)predicate
{
    BOOL result __block = NO;
    [[self.dataSections copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = [(XLDataSectionStore *)obj removeDataItemMatchingPredicate:predicate];
        if (result){
            *stop = YES;
        }
    }];
    return result;
}

-(BOOL)removeDataItemsMatchingPredicate:(NSPredicate *)predicate
{
    BOOL result __block = NO;
    [self.dataSections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = result || [(XLDataSectionStore *)obj removeDataItemsMatchingPredicate:predicate];
    }];
    return result;
}

-(void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"dataSections"];
    }
    @catch (NSException *exception) {}
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!self.delegate) return;
    if ([keyPath isEqualToString:@"dataSections"]){
        if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeInsertion)]){
            NSArray * newSections = [change objectForKey:NSKeyValueChangeNewKey];
            [self.delegate dataStoreWillChangeContent:self];
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            NSUInteger index __block = 0;
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [self.delegate dataStore:self didChangeSection:newSections[index++] atIndex:idx forChangeType:XLDataStoreChangeTypeInsert];
            }];
            [self.delegate dataStoreDidChangeContent:self];
        }
        else if ([[change objectForKey:NSKeyValueChangeKindKey] isEqualToNumber:@(NSKeyValueChangeRemoval)]){
            NSIndexSet * indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
            [self.delegate dataStoreWillChangeContent:self];
            [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [self.delegate dataStore:self didChangeSection:nil atIndex:idx forChangeType:XLDataStoreChangeTypeDelete];
            }];
            [self.delegate dataStoreDidChangeContent:self];
        }
    }
}


#pragma mark - KVC

-(NSUInteger)countOfDataSections
{
    return self.dataSections.count;
}


-(id)objectInDataSectionsAtIndex:(NSUInteger)index
{
    return [self.dataSections objectAtIndex:index];
}

-(NSArray *)dataSectionsAtIndexes:(NSIndexSet *)indexes
{
    return [self.dataSections objectsAtIndexes:indexes];
}

-(void)insertObject:(XLDataSectionStore *)object inDataSectionsAtIndex:(NSUInteger)index
{
    object.dataStore = self;
    [self.dataSections insertObject:object atIndex:index];
}

-(void)removeObjectFromDataSectionsAtIndex:(NSUInteger)index
{
    XLDataSectionStore * dataSection = [self objectInDataSectionsAtIndex:index];
    dataSection.dataStore = nil;
    [self.dataSections removeObjectAtIndex:index];
}

@end
