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

#import "XLData.h"
#import "MenuTableViewController.h"

@interface MenuTableViewController ()

@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [self.dataStore addDataSection:[XLDataSectionStore dataSectionStoreWithTitle:@"DATA STORE"]];
    [self.dataStore addDataItem:@"Data Store TableView"];
    [self.dataStore addDataItem:@"Data Store CollectionView"];
    
    [self.dataStore addDataSection:[XLDataSectionStore dataSectionStoreWithTitle:@"REMOTE DATA STORE"]];
    [self.dataStore addDataItem:@"Remote Data Store TableView"];
    [self.dataStore addDataItem:@"Remote Data Store CollectionView"];
    
    [self.dataStore addDataSection:[XLDataSectionStore dataSectionStoreWithTitle:@"CORE DATA"]];
    [self.dataStore addDataItem:@"Core Data TableView"];
    [self.dataStore addDataItem:@"Core Data CollectionView"];
    
    [self.dataStore addDataSection:[XLDataSectionStore dataSectionStoreWithTitle:@"REMOTE CORE DATA"]];
    [self.dataStore addDataItem:@"Remote Core Data TableView"];
    [self.dataStore addDataItem:@"Remote Core Data CollectionView"];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [self.dataStore dataAtIndexPath:indexPath];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellText = [self.dataStore dataAtIndexPath:indexPath];
    [self performSegueWithIdentifier:cellText sender:nil];
}

-(UITableViewRowAnimation)tableViewAnimationForDataStoreSectionChange:(XLDataStoreChangeType)dataStoreChange
{
    return UITableViewRowAnimationNone;
}


@end
