//
//  XLDataStoreController.m
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

#import "XLDataStoreController.h"

@interface XLDataStoreController()

@property (nonatomic) XLDataControllerType dataStoreControllerType;

@end

@implementation XLDataStoreController
{
    NSMutableArray * _collectionViewObjectChanges;
    NSMutableArray * _collectionViewSectionChanges;
 
    BOOL _isEmptyState;
    
}


@synthesize dataStore = _dataStore;
@synthesize emptyDataSetView;

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
        [self initializeXLDataStoreController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeXLDataStoreController];
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

-(void)initializeXLDataStoreController
{
    _isEmptyState = NO;
    self.dataStore =  nil;
}


-(void)reloadDataSet
{
    [[self mainDataSetView] reloadData];
}

#pragma mark - Properties

-(XLDataStore *)dataStore
{
    if (_dataStore) return _dataStore;
    _dataStore = [[XLDataStore alloc] initWithDelegate:self];
    return _dataStore;
}

-(void)setDataStore:(XLDataStore *)dataStore
{
    _dataStore.delegate = nil;
    _dataStore = dataStore;
    dataStore.delegate = self;
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
    [self reloadDataSet];
    [self updateEmptyDataSetOverlayIfNeeded:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self mainDataSetView] flashScrollIndicators];
}

#pragma mark - XLDataStoreDelegate

-(void)dataStoreWillChangeContent:(XLDataStore *)dataStore
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        [self.tableView beginUpdates];
    }
    else{
        [_collectionViewSectionChanges removeAllObjects];
        [_collectionViewObjectChanges removeAllObjects];
    }
}

-(void)dataStoreDidChangeContent:(XLDataStore *)dataStore
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        [self tableViewEndUpdates];
    }
    else{
        [self collectionViewEndUpdates];
    }
    [self didChangeContent];
}

-(void)dataStore:(XLDataStore *)dataStore didChangeSection:(XLDataSectionStore *)sectionStore atIndex:(NSUInteger)sectionIndex forChangeType:(XLDataStoreChangeType)type
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        switch (type) {
            case XLDataStoreChangeTypeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:[self tableViewAnimationForDataStoreSectionChange:type]];
                break;
            case XLDataStoreChangeTypeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:[self tableViewAnimationForDataStoreSectionChange:type]];
                break;
            case XLDataStoreChangeTypeUpdate:
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:[self tableViewAnimationForDataStoreSectionChange:type]];
                break;
            default:
                NSParameterAssert(YES);
                break;
        }
    }
    else {
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type) {
            case XLDataStoreChangeTypeInsert:
                change[@(type)] = @(sectionIndex);
                break;
            case XLDataStoreChangeTypeDelete:
                change[@(type)] = @(sectionIndex);
                break;
            default:
                NSParameterAssert(YES);
        }
        [_collectionViewSectionChanges addObject:change];
    }
}

-(void)dataStore:(XLDataStore *)dataStore didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(XLDataStoreChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        switch (type) {
            case XLDataStoreChangeTypeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:[self tableViewAnimationForDataStoreItemChange:type]];
                break;
            case XLDataStoreChangeTypeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self tableViewAnimationForDataStoreItemChange:type]];
                break;
            case XLDataStoreChangeTypeMove:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:[self tableViewAnimationForDataStoreItemChange:type]];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:[self tableViewAnimationForDataStoreItemChange:type]];
                break;
            case XLDataStoreChangeTypeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:[self tableViewAnimationForDataStoreItemChange:type]];
                break;
        }
    }
    else {
        NSMutableDictionary *change = [NSMutableDictionary new];
        switch (type){
            case XLDataStoreChangeTypeInsert:
                change[@(type)] = newIndexPath;
                break;
            case XLDataStoreChangeTypeDelete:
                change[@(type)] = indexPath;
                break;
            default:
                NSParameterAssert(YES);
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
    return [self.dataStore totalNumberOfItems];
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

-(id)mainDataSetView
{
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        return self.tableView;
    }
    return self.collectionView;
}

-(void)tableViewEndUpdates
{
    if (!self.tableView.window){
        [self reloadDataSet];
    }
    [self.tableView endUpdates];
}

-(void)collectionViewEndUpdates
{
    if ([_collectionViewSectionChanges count] > 0){
        if (!self.collectionView.window) {
            [self reloadDataSet];
        }
        else{
            [self.collectionView performBatchUpdates:^{
                
                for (NSDictionary *change in _collectionViewSectionChanges){
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        
                        XLDataStoreChangeType type = [key unsignedIntegerValue];
                        switch (type)
                        {
                            case XLDataStoreChangeTypeInsert:
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            case XLDataStoreChangeTypeDelete:
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
                            XLDataStoreChangeType type = [key unsignedIntegerValue];
                            switch (type)
                            {
                                case XLDataStoreChangeTypeInsert:
                                    [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                    break;
                                case XLDataStoreChangeTypeDelete:
                                    [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                    break;
                                case XLDataStoreChangeTypeUpdate:
                                    [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                    break;
                                case XLDataStoreChangeTypeMove:
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
            XLDataStoreChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case XLDataStoreChangeTypeInsert:
                    shouldReload =  ([self.collectionView numberOfItemsInSection:indexPath.section] == 0);
                    break;
                case XLDataStoreChangeTypeDelete:
                    shouldReload = ([self.collectionView numberOfItemsInSection:indexPath.section] == 1);
                    break;
                case XLDataStoreChangeTypeUpdate:
                case XLDataStoreChangeTypeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    return shouldReload;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.tableView == tableView){
        return [self.dataStore numberOfSections];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.tableView == tableView){
        return [self.dataStore numberOfItemsInSection:section];
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
        return [[self.dataStore sectionAtIndex:section] title];
    }
    return nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.collectionView == collectionView){
        return [self.dataStore numberOfSections];
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.collectionView == collectionView){
        return [self.dataStore numberOfItemsInSection:section];
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
        if ((_isEmptyState = [self isEmptyDataSet])) {
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


-(UITableViewRowAnimation)tableViewAnimationForDataStoreSectionChange:(XLDataStoreChangeType)dataStoreChange
{
    return UITableViewRowAnimationAutomatic;
}

-(UITableViewRowAnimation)tableViewAnimationForDataStoreItemChange:(XLDataStoreChangeType)dataStoreChange
{
    return UITableViewRowAnimationAutomatic;
}

#pragma mark - XLDataController

-(BOOL)isEmptyDataSet
{
    return self.dataStore.isEmpty;
}


@end
