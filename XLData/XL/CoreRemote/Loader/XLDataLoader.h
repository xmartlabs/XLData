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

@import Foundation;
#import <AFNetworking/AFNetworking.h>
#import "XLDataLoader.h"


extern NSString * const XLDataLoaderErrorDomain;
extern NSString * const kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse;

@protocol XLDataLoaderDelegate;

@interface XLDataLoader : NSObject
{
    BOOL _isLoadingData;
    BOOL _hasMoreToLoad;
    NSUInteger _offset;
    NSUInteger _limit;
    NSString * _searchString;
}


@property (weak) id<XLDataLoaderDelegate> delegate;

@property (readonly) NSString * URLString;
@property NSUInteger offset;
@property NSUInteger limit;
@property NSString * searchString;
@property (nonatomic) NSMutableDictionary * parameters;
@property (nonatomic) NSString * collectionKeyPath;
@property (readonly) NSDictionary * loadedData;
@property (readonly) NSArray * loadedDataItems;

-(instancetype)initWithDelegate:(id<XLDataLoaderDelegate>)self
                      URLString:(NSString *)urlString;
-(instancetype)initWithDelegate:(id<XLDataLoaderDelegate>)delegate
                      URLString:(NSString *)URLString
                offsetParamName:(NSString *)offsetParamName
                 limitParamName:(NSString *)limitParamName
          searchStringParamName:(NSString *)searchStringParamName;

-(void)load;
-(void)forceLoad:(BOOL)defaultValues;

-(BOOL)isLoadingData;
-(BOOL)hasMoreToLoad;

-(void)cancelRequest; // cancels the active request
// method called after a successful data load, if overwritten by a subclass don't forget to call super method (delegate is called from there).
-(void)successulDataLoad;
// method called after a failure on data load, if overwritten by a subclass don't forget to call super method (delegate is called from there).
-(void)unsuccessulDataLoadWithError:(NSError *)error;

@end




@protocol XLDataLoaderDelegate <NSObject>

@optional
-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataLoader withError:(NSError *)error;

-(AFHTTPSessionManager *)sessionManagerForDataLoader:(XLDataLoader *)dataLoader;
-(id)dataLoader:(XLDataLoader *)dataLoader convertJsonItemToModelObject:(id)item;

@end

