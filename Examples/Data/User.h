//
//  User.h
//  XLData
//
//  Created by Martin Barreto on 5/24/15.
//  Copyright (c) 2015 Xmartlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userImageURL;
@property (nonatomic, retain) NSString * userName;

@end
