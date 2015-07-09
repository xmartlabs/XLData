//
//  UsersRemoteCoreDataTableViewController.m
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

#import "UserCollectionCell.h"
#import "UserTableCell.h"
#import "HTTPSessionManager.h"
#import "XLData.h"
#import "UsersRemoteCoreDataController.h"
#import "CoreDataStore.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UsersRemoteDataStoreController.h"

@interface UsersRemoteCoreDataController()<UISearchControllerDelegate>

@property (nonatomic, readonly) UsersRemoteDataStoreController * searchResultController;
@property (nonatomic, readonly) UISearchController * searchController;

@end

@implementation UsersRemoteCoreDataController

@synthesize searchController = _searchController;
@synthesize searchResultController = _searchResultController;

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.dataLoader = [[XLDataLoader alloc] initWithDelegate:self URLString:@"/mobile/users.json"];
        self.dataLoader.limit = 4;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[User getFetchRequest] managedObjectContext:[CoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    // CollectionView
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.allowsSelection = NO;
    UICollectionViewFlowLayout *collectionLayout = (id)self.collectionView.collectionViewLayout;
    collectionLayout.itemSize = CGSizeMake(100.0, 100.0);
    
    [super viewDidLoad];
    
    // TableView
    [self.tableView registerClass:[UserTableCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
    
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableCell * cell = (UserTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    User * dataItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.userName.text = [dataItem.userName copy];
    [cell.userImage setImageWithURL:[NSURL URLWithString:[dataItem.userImageURL copy]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionCell * cell = (UserCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    User * dataItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.userImage setImageWithURL:[NSURL URLWithString:dataItem.userImageURL] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0f;
}

#pragma mark - XLDataLoaderDelegate

-(AFHTTPSessionManager *)sessionManagerForDataLoader:(XLDataLoader *)dataLoader
{
    return [HTTPSessionManager sharedClient];
}

#pragma mark - XLRemoteControllerDelegate

-(void)dataController:(UIViewController *)controller updateDataWithDataLoader:(XLDataLoader *)dataLoader
{
    NSUInteger offset = dataLoader.offset;
    NSUInteger limit = dataLoader.limit;
    NSArray * itemsArray = [dataLoader loadedDataItems];
    // This flag indicates if there is more data to load
    [[CoreDataStore privateQueueContext] performBlock:^{
        for (NSDictionary *item in itemsArray) {
            // Creates or updates the User a with the data that came from the server
            [User createOrUpdateWithServiceResult:item[@"user"] inContext:[CoreDataStore privateQueueContext]];
        }
        
        // Remove outdated data
        NSFetchRequest * fetchRequest = [User getFetchRequest];
        fetchRequest.fetchLimit = limit;
        fetchRequest.fetchOffset = offset;
        
        NSError *error;
        NSArray * oldObjects = [[CoreDataStore privateQueueContext] executeFetchRequest:fetchRequest error:&error];
        NSArray * arrayToIterate = [oldObjects copy];
        for (User *user in arrayToIterate){
            NSArray *filteredArray = [itemsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"user.id = %@" argumentArray:@[user.userId]]];
            if (filteredArray.count == 0) {
                // This User no longer exists
                [[CoreDataStore privateQueueContext] deleteObject:user];
            }
        }
        //
        [CoreDataStore savePrivateQueueContext];
    }];
}

#pragma mark - Actions


- (IBAction)searchTapped:(UIBarButtonItem *)sender
{
    [self.searchController setActive:YES];
}

#pragma mark - UISearchController

-(UISearchController *)searchController
{
    // UISearchController
    if (_searchController) return _searchController;
    self.definesPresentationContext = YES;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
    _searchController.searchResultsUpdater = self.searchResultController;
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchController.searchBar sizeToFit];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.delegate = self;
    return _searchController;
}

-(UsersRemoteDataStoreController *)searchResultController
{
    if (_searchResultController) return _searchResultController;
    _searchResultController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchUsersTableViewController"];
    _searchResultController.dataLoader.limit = 0; // no paging in search result
    _searchResultController.isSearchResultsController = YES;
    return _searchResultController;
}

#pragma mark -  UISearchControllerDelegate

-(void)presentSearchController:(UISearchController *)searchController
{
    if ([searchController.delegate respondsToSelector:@selector(willPresentSearchController:)]){
        [searchController.delegate willPresentSearchController:searchController];
    }
    [self.navigationController presentViewController:searchController animated:YES completion:^{
        if ([searchController.delegate respondsToSelector:@selector(didPresentSearchController:)]){
            [searchController.delegate didPresentSearchController:searchController];
        }
    }];
}


- (void)didPresentSearchController:(UISearchController *)searchController
{
    [searchController.searchBar becomeFirstResponder];
}

@end
