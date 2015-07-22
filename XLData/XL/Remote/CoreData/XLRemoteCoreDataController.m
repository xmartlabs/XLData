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

#import "XLDataStore.h"
#import "XLNetworkStatusView.h"
#import "XLSearchBar.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "XLRemoteCoreDataController.h"


@implementation XLRemoteCoreDataController
{
    UIView * _networkStatusView;
    NSTimer * _searchDelayTimer;
    BOOL _isConnectedToInternet;
}

@synthesize dataLoader = _dataLoader;
@synthesize refreshControl = _refreshControl;
@synthesize remoteControllerDelegate = _remoteControllerDelegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeXLRemoteCoreDataController];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeXLRemoteCoreDataController];
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

-(void)initializeXLRemoteCoreDataController
{
    _networkStatusView = nil;
    _searchDelayTimer = nil;
    self.options = XLRemoteDataStoreControllerOptionDefault;
    self.dataLoader = nil;
    _isConnectedToInternet = YES;
}

#pragma mark - Properties

-(UIRefreshControl *)refreshControl
{
    if (_refreshControl) return _refreshControl;
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    return _refreshControl;
}

-(UIView *)networkStatusView
{
    if (!_networkStatusView){
        _networkStatusView = [XLNetworkStatusView new];
        _networkStatusView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:_networkStatusView];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[networkStatusView]|" options:0 metrics:0 views:@{@"networkStatusView": _networkStatusView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][networkStatusView(30)]" options:0 metrics:0 views:@{@"networkStatusView": _networkStatusView, @"topLayoutGuide": self.topLayoutGuide}]];
        [self.view sendSubviewToBack:_networkStatusView];
    }
    return _networkStatusView;
}


-(id<XLRemoteControllerDelegate>)remoteControllerDelegate
{
    if (_remoteControllerDelegate){
        return _remoteControllerDelegate;
    }
    return self;
}

-(void)setRemoteControllerDelegate:(id<XLRemoteControllerDelegate>)remoteControllerDelegate
{
    _remoteControllerDelegate = remoteControllerDelegate;
}

#pragma mark - UIViewController life cycle.


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ((self.options & XLRemoteDataStoreControllerOptionSupportRefreshControl) ==  XLRemoteDataStoreControllerOptionSupportRefreshControl){
        if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
            [self.tableView addSubview:self.refreshControl];
        }
        else{
            [self.collectionView addSubview:self.refreshControl];
        }
    }
    if ((self.options & XLRemoteDataStoreControllerOptionPagingEnabled) == XLRemoteDataStoreControllerOptionPagingEnabled){
        __typeof__(self) __weak weakSelf = self;
        if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                if (!weakSelf.dataLoader.isLoadingData){
                    [weakSelf.tableView.infiniteScrollingView startAnimating];
                    weakSelf.dataLoader.offset = weakSelf.dataLoader.offset + weakSelf.dataLoader.limit;
                    [weakSelf.dataLoader load];
                }
            }];
        }
        else{
            [self.collectionView addInfiniteScrollingWithActionHandler:^{
                if (!weakSelf.dataLoader.isLoadingData){
                    [weakSelf.collectionView.infiniteScrollingView startAnimating];
                    weakSelf.dataLoader.offset = weakSelf.dataLoader.offset + weakSelf.dataLoader.limit;
                    [weakSelf.dataLoader load];
                }
            }];
        }
    }
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.fetchedResultsController.fetchRequest setFetchLimit:(self.dataLoader.limit == 0 ? 0 : (self.dataLoader.offset + self.dataLoader.limit))];
    NSError * error;
    [self.fetchedResultsController performFetch:&error];
    self.dataStoreControllerType == XLDataStoreControllerTypeTableView ? [self.tableView reloadData] : [self.collectionView reloadData];
    
    if (!((self.options & XLRemoteDataStoreControllerOptionsFetchOnlyOnce) == XLRemoteDataStoreControllerOptionsFetchOnlyOnce)|| self.isBeingPresented || self.isMovingToParentViewController){
        if (!((self.options & XLRemoteDataStoreControllerOptionsSkipInitialFetch) == XLRemoteDataStoreControllerOptionsSkipInitialFetch)){
            [self.dataLoader forceLoad:NO];
        }
    }
    if ((self.options & XLRemoteDataStoreControllerOptionShowNetworkReachability) == XLRemoteDataStoreControllerOptionShowNetworkReachability){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(networkingReachabilityDidChange:)
                                                     name:AFNetworkingReachabilityDidChangeNotification
                                                   object:nil];
        [self updateNoInternetConnectionOverlayIfNeeded:NO];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AFNetworkingReachabilityDidChangeNotification object:nil];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    self.fetchedResultsController.fetchRequest.fetchOffset = 0;
    self.fetchedResultsController.fetchRequest.fetchLimit = self.dataLoader.limit;
    [self.fetchedResultsController performFetch:nil];
    if (self.dataLoader){
        [[self dataSetView] reloadData];
        [self.dataLoader forceLoad:YES];
    }
    else{
        [[[self dataSetView] infiniteScrollingView] stopAnimating];
        [self.refreshControl endRefreshing];
    }
}


#pragma mark - XLRemoteControllerDelegate

-(void)dataController:(UIViewController *)controller showNoInternetConnection:(BOOL)animated
{
    __weak __typeof(self)weakSelf = self;
    weakSelf.networkStatusView.alpha = 0.0;
    [self.networkStatusView.superview bringSubviewToFront:self.networkStatusView];
    [UIView animateWithDuration:(animated ? 0.5 : 0.0)
                          delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear)
                     animations:^{
                         weakSelf.networkStatusView.alpha = 1.0f;
                     }
                     completion:nil];
}

-(void)dataController:(UIViewController *)controller hideNoInternetConnection:(BOOL)animated
{
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:(animated ? 0.5 : 0.0) delay:0.0
                        options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionOverrideInheritedDuration | UIViewAnimationCurveLinear)
                     animations:^{
                         weakSelf.networkStatusView.alpha = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         if (finished && _isConnectedToInternet){
                             [weakSelf.networkStatusView.superview sendSubviewToBack:weakSelf.networkStatusView];
                         }
                     }];
}

#pragma mark - XLDataLoaderDelegate

-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader
{
    if (dataLoader == self.dataLoader){
        if ((self.options & XLRemoteDataStoreControllerOptionPagingEnabled) == XLRemoteDataStoreControllerOptionPagingEnabled){
            [[[self dataSetView] infiniteScrollingView] startAnimating];
        }
    }
}
         
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataLoader
{
    if (dataLoader == self.dataLoader){
        UIScrollView * scrollView = [self dataSetView];
        [scrollView.infiniteScrollingView stopAnimating];
        [self.refreshControl endRefreshing];
        scrollView.infiniteScrollingView.enabled = dataLoader.hasMoreToLoad;
        [self.fetchedResultsController.fetchRequest setFetchLimit:(self.dataLoader.limit == 0 ? 0 : (self.dataLoader.offset + self.dataLoader.limit))];
    }
}

-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataLoader withError:(NSError *)error
{
    if (dataLoader == self.dataLoader){
        [[[self dataSetView] infiniteScrollingView] stopAnimating];
        [self.refreshControl endRefreshing];
    }
    if (error.code != NSURLErrorCancelled && (error.code != NSURLErrorNotConnectedToInternet || ((self.options & XLRemoteDataStoreControllerOptionShowNetworkConnectivityErrors) == XLRemoteDataStoreControllerOptionShowNetworkConnectivityErrors))){
        [self showError:error];
    }
}

-(AFHTTPSessionManager *)sessionManagerForDataLoader:(XLDataLoader *)dataLoader
{
    @throw [NSException exceptionWithName:NSGenericException
                                   reason:[NSString stringWithFormat:@"%s must be overridden in a subclass", __PRETTY_FUNCTION__]
                                 userInfo:nil];
}


#pragma mark - Helpers

-(void)networkingReachabilityDidChange:(NSNotification *)notification
{
    [self updateNoInternetConnectionOverlayIfNeeded:YES];
}

-(void)updateNoInternetConnectionOverlayIfNeeded:(BOOL)animated
{
    AFHTTPSessionManager * sessionManager;
    if ( !(sessionManager = ([self sessionManagerForDataLoader:self.dataLoader])) || (_isConnectedToInternet = ([sessionManager.reachabilityManager
                                    networkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable))){
        [self.remoteControllerDelegate dataController:self hideNoInternetConnection:animated];
    }
    else{
        [self.remoteControllerDelegate dataController:self showNoInternetConnection:animated];
    }
}

-(id)dataSetView
{
    
    if (self.dataStoreControllerType == XLDataStoreControllerTypeTableView){
        return self.tableView;
    }
    return self.collectionView;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController;
{
    [super updateSearchResultsForSearchController:searchController];
    [self.dataLoader setSearchString:[searchController.searchBar.text copy]];
    [self.dataLoader forceLoad:YES];
}


@end
