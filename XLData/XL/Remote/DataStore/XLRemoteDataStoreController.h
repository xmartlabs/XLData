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
#import "XLDataStoreController.h"
#import "XLDataStore.h"
#import "XLDataLoader.h"
#import "XLSearchBar.h"
#import "XLRemoteControllerDelegate.h"

@interface XLRemoteDataStoreController : XLDataStoreController<XLDataLoaderDelegate, XLDataLoaderStoreDelegate, UISearchResultsUpdating, XLRemoteControllerDelegate>

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;

/**
 *  XLDataLoader helps us out with networking stuff. Concrete view controller implementation must conforms to XLDataLoaderDelegate and provides it  with the necessary data (url, session manager, etc) to make it work.
 */
@property (nonatomic) XLDataLoader * dataLoader;

/**
 *  You can use options property to enable/disable controller functionality.
 */
@property XLRemoteControllerOptions options;

/**
 *  networkStatusView is shown when device doesn't have internet connection
 */
@property (nonatomic) IBOutlet UIView * networkStatusView;
@property (readonly) UIRefreshControl * refreshControl;

@property id<XLRemoteControllerDelegate> remoteControllerDelegate;

@end
