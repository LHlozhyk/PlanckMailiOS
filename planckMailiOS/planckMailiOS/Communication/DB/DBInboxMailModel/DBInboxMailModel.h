//
//  DBInboxMailModel.h
//  planckMailiOS
//
//  Created by nazar on 10/29/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DBNamespace;

NS_ASSUME_NONNULL_BEGIN

@interface DBInboxMailModel : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
+ (DBInboxMailModel*)createNewMailModelFromDictionary:(NSDictionary*)item;

@end

NS_ASSUME_NONNULL_END

#import "DBInboxMailModel+CoreDataProperties.h"
