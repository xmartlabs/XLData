//
//  XLDataStoreController.h
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

#import "XLDataStore.h"
#import "XLData.h"
@import UIKit;

@interface XLDataStoreController : UIViewController<XLDataStoreDelegate,  UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, XLDataController>

/**
 *  Convenient Initializer to create a view controller that handles a table view or a collection view.
 *
 *  @param controllerType type of view that the view controller manages.
 *
 *  @return initialized XLCoreDataController instance.
 */
- (instancetype)initWithDataStoreControllerType:(XLDataControllerType)controllerType;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 *  data store used to load the data, view controller keeps track of it in order to update the table/collection view accordingly.
 */
@property XLDataStore * dataStore;

/**
 *  returns the type of the controller. Data can be shown using a table view or a collection view depending of the initializer invoked or if you connect the table view or the collection view outlets.
 */
@property (nonatomic, readonly) XLDataControllerType dataStoreControllerType;

@property (nonatomic) IBOutlet UITableView * tableView;
@property (nonatomic) IBOutlet UICollectionView * collectionView;

@property (nonatomic) IBOutlet UISearchBar * searchBar;

/**
 *  View used as background when tableView or collectionView is Empty.
 */
@property (nonatomic) IBOutlet UIView * emptyDataSetView;


-(void)reloadDataSet;

@end


@interface XLDataStoreController (__Protected)

/**
 *  UIAlertView is used by default to show errors. Override if you want to show the error differently.
 *
 *  @param error Error to be shown.
 */
-(void)showError:(NSError*)error;

/**
 *  This method is invoked each time the table or collection view content changes.
 */
-(void)didChangeContent;


/**
 *  Override if you want to show the emptyStateView with a differnt animation.
 *
 *  @param animated if YES perform a animated transition/
 */
-(void)showEmptyStateView:(BOOL)animated;
/**
 *  Override if you want to hide the emptyStateView with a differnt animation.
 *
 *  @param animated if YES perform a animated transition/
 */
-(void)hideEmptyStateView:(BOOL)animated;


/**
 *  Override to change the animation used when a section is added, removed, etc.
 *
 *  @param dataStoreChange kind of section data store modification
 *
 *  @return animation to be used
 */
-(UITableViewRowAnimation)tableViewAnimationForDataStoreSectionChange:(XLDataStoreChangeType)dataStoreChange;


/**
 *  Override to change the animation used when a item is added, removed, etc.
 *
 *  @param dataStoreChange kind of item data store modification
 *
 *  @return animation to be used
 */
-(UITableViewRowAnimation)tableViewAnimationForDataStoreItemChange:(XLDataStoreChangeType)dataStoreChange;

@end

