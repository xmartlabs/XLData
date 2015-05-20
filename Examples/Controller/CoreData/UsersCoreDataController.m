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
#import "XLData.h"
#import "UsersCoreDataController.h"
#import "CoreDataStore.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation UsersCoreDataController


-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[User getFetchRequest] managedObjectContext:[CoreDataStore mainQueueContext] sectionNameKeyPath:nil cacheName:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Table View
    [self.tableView registerClass:[UserTableCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [UIView new];
    
    // Collection View
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    UICollectionViewFlowLayout *collectionLayout = (id)self.collectionView.collectionViewLayout;
    collectionLayout.itemSize = CGSizeMake(100.0, 100.0);
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

@end
