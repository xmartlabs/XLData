//
//  UsersDataStoreController.m
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

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "UserTableCell.h"
#import "UserCollectionCell.h"
#import "UsersDataStoreController.h"

@interface UsersDataStoreController ()

@end

@implementation UsersDataStoreController
{
    UIAlertController * __weak _alertController;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TableView
    [self.tableView registerClass:[UserTableCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // CollectionView
    [self.collectionView registerClass:[UserCollectionCell class] forCellWithReuseIdentifier:@"cell"];
    UICollectionViewFlowLayout *collectionLayout = (id)self.collectionView.collectionViewLayout;
    collectionLayout.itemSize = CGSizeMake(100.0, 100.0);
    
    // add default users users
    [self.dataStore addDataItem:@{
                                  @"imageURL": @"http://obscure-refuge-3149.herokuapp.com/images/Bart_Simpsons.png",
                                  @"name": @"Bart Simpsons"
                                  }];
    [self.dataStore addDataItem:@{
                                  @"imageURL": @"http://obscure-refuge-3149.herokuapp.com/images/Homer_Simpsons.png",
                                  @"name": @"Homer Simpsons"
                                  }];
    [self.dataStore addDataItem:@{
                                  @"imageURL": @"http://obscure-refuge-3149.herokuapp.com/images/Lisa_Simpsons.png",
                                  @"name": @"Lisa Simpsons"
                                  }];
    [self.dataStore addDataItem:@{
                                  @"imageURL": @"http://obscure-refuge-3149.herokuapp.com/images/Marge_Simpsons.png",
                                  @"name": @"Marge Simpsons"
                                  }];
    
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableCell * cell = (UserTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary * dataItem = [self.dataStore dataAtIndexPath:indexPath];
    
    cell.userName.text = [dataItem valueForKeyPath:@"name"];
    [cell.userImage setImageWithURL:[NSURL URLWithString:[dataItem valueForKeyPath:@"imageURL"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}

#pragma mark - UICollectionViewDataSource

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UserCollectionCell * cell = (UserCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary * dataItem = [self.dataStore dataAtIndexPath:indexPath];

    [cell.userImage setImageWithURL:[NSURL URLWithString:[dataItem valueForKeyPath:@"imageURL"]] placeholderImage:[UIImage imageNamed:@"default-avatar"]];
    return cell;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    XLDataSectionStore * section = [self.dataStore sectionAtIndex:indexPath.section];
    [section removeDataItemAtIndex:indexPath.row];
    if ([section numberOfItems] == 0){
        [self.dataStore removeDataSection:section];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}



#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 73.0f;
}


#pragma mark - Actions

- (IBAction)addAction:(UIBarButtonItem *)sender
{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Create a User" message:@"Please enter a name for the user.." preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    UIAlertAction * action = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString * text = [[alertController.textFields firstObject] text];
        [self.dataStore addDataItem:@{
                                      @"imageURL": @"",
                                      @"name": [text copy]
                                      }];
    }];
    action.enabled = NO;
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
    _alertController = alertController;
}

#pragma mark - Events

-(void)textFieldDidChange:(UITextField *)textField
{
    [_alertController.actions[1] setEnabled:(textField.text.length > 0)];
}



@end
