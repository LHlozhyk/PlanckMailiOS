//
//  DBNamespace.h
//  planckMailiOS
//
//  Created by admin on 5/25/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PMAccountProtocol.h"

@interface DBNamespace : NSManagedObject <PMAccountProtocol>
@property (nonatomic, retain) NSString * object;
@property (nonatomic, retain) NSString * email_address;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * provider;
@end
