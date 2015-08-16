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


extern NSString * const kXLDataLoaderErrorDomain;
extern NSString * const kXLRemoteDataLoaderDefaultKeyForNonDictionaryResponse;


@class XLDataLoader;

@protocol XLDataLoaderDelegate <NSObject>

@required
-(AFHTTPSessionManager *)sessionManagerForDataLoader:(XLDataLoader *)dataLoader;

@optional
-(void)dataLoaderDidStartLoadingData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidLoadData:(XLDataLoader *)dataLoader;
-(void)dataLoaderDidFailLoadData:(XLDataLoader *)dataLoader withError:(NSError *)error;

@end

@protocol XLDataLoaderStoreDelegate <NSObject>

@optional
-(NSDictionary *)dataLoader:(XLDataLoader *)dataLoader convertJsonDataToModelObject:(NSDictionary *)data;
-(void)dataLoaderUpdateDataStore:(XLDataLoader *)dataLoader completionHandler:(void (^)())completionHandler;

@end

@interface XLDataLoader : NSObject <XLDataLoaderDelegate>
{
    BOOL _isLoadingData;
    BOOL _hasMoreToLoad;
    NSUInteger _offset;
    NSUInteger _limit;
    NSString * _searchString;
}


@property (weak, nonatomic) id<XLDataLoaderDelegate> delegate;
@property (weak, nonatomic) id<XLDataLoaderStoreDelegate> storeDelegate;

@property (readonly) NSString * URLString;
@property NSUInteger offset;
@property NSUInteger limit;
@property NSString * searchString;
@property (nonatomic) NSMutableDictionary * parameters;
@property (nonatomic) NSString * collectionKeyPath;
@property (readonly) NSDictionary * loadedData;
@property (readonly) NSArray * loadedDataItems;

-(instancetype)initWithURLString:(NSString *)URLString;
-(instancetype)initWithURLString:(NSString *)URLString
                offsetParamName:(NSString *)offsetParamName
                 limitParamName:(NSString *)limitParamName
          searchStringParamName:(NSString *)searchStringParamName;

-(void)load;
-(void)forceLoad:(BOOL)defaultValues;

-(BOOL)isLoadingData;
-(BOOL)hasMoreToLoad;

-(void)cancelRequest; // cancels the active request

@end






