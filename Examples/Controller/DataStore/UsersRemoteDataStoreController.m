//
//  UsersTableViewController.m
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
#import "HTTPSessionManager.h"
#import "UserTableCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UsersRemoteDataStoreController.h"


@interface UsersRemoteDataStoreController () <UISearchControllerDelegate>

@property (nonatomic, readonly) UsersRemoteDataStoreController * searchResultController;
@property (nonatomic, readonly) UISearchController * searchController;
@property IBOutlet UIView * searchBarContainer;

@end

@implementation UsersRemoteDataStoreController

@synthesize searchController = _searchController;
@synthesize searchResultController = _searchResultController;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.isSearchResultsController = NO;
        self.dataLoader =  [[XLDataLoader alloc] initWithURLString:@"/mobile/users.json" offsetParamName:@"offset" limitParamName:@"limit" searchStringParamName:@"filter"];
        self.dataLoader.delegate = self;
        self.dataLoader.storeDelegate = self;
        self.dataLoader.limit = 4;
        self.dataLoader.collectionKeyPath = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // TableView
    [self.tableView registerClass:[UserTableCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.allowsSelection = NO;
    
    // CollectionView
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    self.collectionView.allowsSelection = NO;
    UICollectionViewFlowLayout *collectionLayout = (id)self.collectionView.collectionViewLayout;
    collectionLayout.itemSize = CGSizeMake(100.0, 100.0);
    
    if (!self.isSearchResultsController){
        if (self.searchBarContainer){
            [self.searchBarContainer addSubview:self.searchController.searchBar];
        }
        else{
            self.tableView.tableHeaderView = self.searchController.searchBar;
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.searchController.searchBar sizeToFit];
}


#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableCell * cell = (UserTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary * dataItem = [self.dataStore dataAtIndexPath:indexPath];
    
    cell.userName.text = [dataItem valueForKeyPath:@"user.name"];
    [cell.userImage setImageWithURL:[NSURL URLWithString:[dataItem valueForKeyPath:@"user.imageURL"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionCell * cell = (UserCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary * dataItem = [self.dataStore dataAtIndexPath:indexPath];
    
    [cell.userImage setImageWithURL:[NSURL URLWithString:[dataItem valueForKeyPath:@"user.imageURL"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}



#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0f;
}

#pragma mark - XLDataLoaderDelegate

-(AFHTTPSessionManager *)sessionManagerForDataLoader:(XLDataLoader *)dataLoader
{
    return [HTTPSessionManager sharedClient];
}

#pragma mark - UISearchController

-(UISearchController *)searchController
{
    if (_searchController) return _searchController;
    
    self.definesPresentationContext = YES;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchResultController];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self.searchResultController;
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_searchController.searchBar sizeToFit];
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

@end

