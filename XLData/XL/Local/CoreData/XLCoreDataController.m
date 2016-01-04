//
//  XLCoreDataController.m
//  XLForm ( https://github.com/xmartlabs/XLData )
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

#import "XLCoreDataController.h"

@interface XLCoreDataController()

@property (nonatomic) XLDataControllerType dataStoreControllerType;

@end

@implementation XLCoreDataController
{
    BOOL _beginUpdates;
    NSMutableArray * _collectionViewObjectChanges;
    NSMutableArray * _collectionViewSectionChanges;
    BOOL _isEmptyState;
}


@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize emptyDataSetView = _emptyDataSetView;

- (instancetype)initWithDataStoreControllerType:(XLDataControllerType)controllerType
{
    self = [self initWithNibName:nil bundle:nil];
    if (self){
        self.dataStoreControllerType = controllerType;
    }
    return self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeXLCoreDataController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeXLCoreDataController];
    }
    return self;
}

-(void)dealloc
{
    self.collectionView.delegate                         = nil;
    self.collectionView.dataSource                       = nil;
    self.tableView.delegate                              = nil;
    self.tableView.dataSource                            = nil;
}

-(void)initializeXLCoreDataController
{
    _beginUpdates                                        = NO;
    self.fetchedResultsController                        = nil;
    _isEmptyState = NO;
}

-(void)reloadDataSet
{
    [self.fetchedResultsController performFetch:nil];
    [[self dataSetView] reloadData];
}

#pragma mark - Properties

-(NSFetchedResultsController *)fetchedResultsController
{
    return _fetchedResultsController;
}

-(void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = fetchedResultsController;
    if ([[self dataSetView] window]){
        _fetchedResultsController.delegate = self;
    }
    [self reloadDataSet];
}

#pragma mark - UIViewController life cycle.

- (void)viewDidLoad
{
    [super viewDidLoad];
    _collectionViewObjectChanges = [NSMutableArray new];
    _collectionViewSectionChanges = [NSMutableArray new];
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        if (!self.tableView){
            self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                          style:UITableViewStylePlain];
            self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        if (!self.tableView.superview){
            [self.view addSubview:self.tableView];
        }
        if (!self.tableView.delegate){
            self.tableView.delegate = self;
        }
        if (!self.tableView.dataSource){
            self.tableView.dataSource = self;
        }
    }
    else if (self.dataStoreControllerType == XLDataStoreControllerTypeCollectionView){
        if (!self.collectionView){
            self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds];
            self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
        if (!self.collectionView.superview){
            [self.view addSubview:self.collectionView];
        }
        if (!self.collectionView.delegate){
            self.collectionView.delegate = self;
        }
        if (!self.collectionView.dataSource){
            self.collectionView.dataSource = self;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.fetchedResultsController.delegate = self;
    [self reloadDataSet];
    [self updateEmptyDataSetOverlayIfNeeded:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self dataSetView] flashScrollIndicators];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.fetchedResultsController.delegate = nil;
}

#pragma mark - NSFetchedResultsControllerDelegate

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView && !_beginUpdates){
        _beginUpdates = YES;
        [self.tableView beginUpdates];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        [self tableViewEndUpdates];
    }
    else{
        [self collectionViewEndUpdates];
    }
    [self didChangeContent];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:[self insertSectionAnimationForIndex:sectionIndex]];
                break;
            case NSFetchedResultsChangeDelete:
                 [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:[self deleteSectionAnimationForIndex:sectionIndex]];
                break;
            default:
                NSParameterAssert(YES);
                break;
        }
    }
    else {
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type) {
            case NSFetchedResultsChangeInsert:
                change[@(type)] = @(sectionIndex);
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = @(sectionIndex);
                break;
            default:
                NSParameterAssert(YES);
        }
        [_collectionViewSectionChanges addObject:change];
    }
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:[self insertRowAnimationForIndexPath:newIndexPath]];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self deleteRowAnimationForIndexPath:indexPath]];
                break;
            case NSFetchedResultsChangeMove:
                // Fix for issue on NSFetchedResultsController: https://forums.developer.apple.com/thread/4999
                // For an updated object, the didChangeObject: delegate method is called twice: Once with the NSFetchedResultsChangeUpdate event and then again with the NSFetchedResultsChangeMove event (and indexPath == newIndexPath). If indexPath with newIndexPath are equal, then the error occures.
                // Beta fix, once Apple comes up with a fix this should be removed
                if (![indexPath isEqual:newIndexPath]) {
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                          withRowAnimation:[self deleteRowAnimationForIndexPath:indexPath]];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                                          withRowAnimation:[self insertRowAnimationForIndexPath:newIndexPath]];
                }
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:[self reloadRowAnimationForIndexPath:newIndexPath]];
                break;
        }
    }
    else {
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type){
            case NSFetchedResultsChangeInsert:
                change[@(type)] = newIndexPath;
                break;
            case NSFetchedResultsChangeDelete:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeUpdate:
                change[@(type)] = indexPath;
                break;
            case NSFetchedResultsChangeMove:
                change[@(type)] = @[indexPath, newIndexPath];
                break;
        }
        [_collectionViewObjectChanges addObject:change];
    }
}


#pragma mark - XLTableViewControllerDelegate

-(void)showError:(NSError*)error
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Opps!", nil)
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Helpers

-(NSUInteger)totalNumberOfItems
{
    return [self.fetchedResultsController.managedObjectContext countForFetchRequest:self.fetchedResultsController.fetchRequest error:nil];
}

-(XLDataControllerType)dataStoreControllerType
{
    if (self.tableView){
        return XLDataStoreControllerTypeTableView;
    }
    else if (self.collectionView){
        return XLDataStoreControllerTypeCollectionView;
    }
    return _dataStoreControllerType;
}


#pragma mark - Helpers

-(void)tableViewEndUpdates
{
    if (_beginUpdates){
        [self.tableView endUpdates];
        _beginUpdates = NO;
    }
}

- (void)collectionViewEndUpdates
{
    if ([_collectionViewSectionChanges count] > 0){
        if (!self.collectionView.window) {
            [self reloadDataSet];
        }
        else{
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _collectionViewSectionChanges){
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            default:
                                NSParameterAssert(YES);
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    else if ([_collectionViewObjectChanges count] > 0){
        if ([self shouldReloadCollectionViewToPreventKnownIssue] || !self.collectionView.window) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self reloadDataSet];
            
        }
        else {
            
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _collectionViewObjectChanges)
                {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case NSFetchedResultsChangeInsert:
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeDelete:
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeUpdate:
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            case NSFetchedResultsChangeMove:
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    [_collectionViewObjectChanges removeAllObjects];
    [_collectionViewSectionChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue {
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _collectionViewObjectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    shouldReload =  ([self.collectionView numberOfItemsInSection:indexPath.section] == 0);
                    break;
                case NSFetchedResultsChangeDelete:
                    shouldReload = ([self.collectionView numberOfItemsInSection:indexPath.section] == 1);
                    break;
                case NSFetchedResultsChangeUpdate:
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    return shouldReload;
}

-(id)dataSetView
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        return self.tableView;
    }
    return self.collectionView;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView){
        return self.fetchedResultsController.sections.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView){
        return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView){
        return [[self.fetchedResultsController.sections objectAtIndex:section] name];
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.collectionView == collectionView){
        return self.fetchedResultsController.sections.count;
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView == collectionView){
        return [[self.fetchedResultsController.sections objectAtIndex:section] numberOfObjects];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Protected

-(void)didChangeContent
{
    [self updateEmptyDataSetOverlayIfNeeded:YES];
}

-(void)updateEmptyDataSetOverlayIfNeeded:(BOOL)animated
{
    if (self.emptyDataSetView){
        if ((_isEmptyState = [self isEmptyDataSet]))
        {
            [self showEmptyStateView:animated];
        }
        else{
            [self hideEmptyStateView:animated];
        }
    }
}

-(void)showEmptyStateView:(BOOL)animated
{
    __weak __typeof(self)weakSelf = self;
    weakSelf.emptyDataSetView.alpha = 0.0;
    [self.emptyDataSetView.superview bringSubviewToFront:self.emptyDataSetView];
    [UIView animateWithDuration:(animated ? 0.5 : 0.0)
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear)
                     animations:^{
                         weakSelf.emptyDataSetView.alpha = 1.0f;
                     }
                     completion:nil];
}

-(void)hideEmptyStateView:(BOOL)animated
{
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:(animated ? 0.5 : 0.0) delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationCurveLinear)
                     animations:^{
                         weakSelf.emptyDataSetView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         if (finished && !_isEmptyState){
                             [weakSelf.emptyDataSetView.superview sendSubviewToBack:weakSelf.emptyDataSetView];
                         }
                     }];
}

-(NSFetchedResultsController *)updateFetchedResultController
{
    return self.fetchedResultsController;
}

-(void)updateFetchedResultControllerIfNeeded
{
    NSFetchedResultsController * frController = [self updateFetchedResultController];
    if (frController != self.fetchedResultsController){
        frController.fetchRequest.fetchLimit = 0;
        frController.fetchRequest.fetchOffset = 0;
        self.fetchedResultsController = frController;
    }
    else{
        self.fetchedResultsController.fetchRequest.fetchLimit = 0;
        self.fetchedResultsController.fetchRequest.fetchOffset = 0;
        [self.fetchedResultsController performFetch:nil];
        [self reloadDataSet];
    }
}

-(UITableViewRowAnimation)insertRowAnimationForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)deleteRowAnimationForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)reloadRowAnimationForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)insertSectionAnimationForIndex:(NSUInteger)sectionIndex
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)deleteSectionAnimationForIndex:(NSUInteger)sectionIndex
{
    return UITableViewRowAnimationAutomatic;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self updateFetchedResultControllerIfNeeded];
}

#pragma mark - XLDataController

-(BOOL)isEmptyDataSet
{
    return (self.fetchedResultsController.sections.count == 0 || (self.fetchedResultsController.sections.count == 1 && ([self.fetchedResultsController.sections[0] numberOfObjects] == 0)));
}


@end
