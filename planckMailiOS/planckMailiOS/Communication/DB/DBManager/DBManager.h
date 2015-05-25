//
//  DBManager.h
//  pfaUkraine
//
//  Created by Admin on 29.10.14.
//  Copyright (c) 2014 Indeema. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "DBNamespace.h"

@interface DBManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) NSArray *namespaces;

- (void)save;
- (NSArray *)getNamespaces;

+ (void)deleteAllDataFromDB;

+ (DBManager *)instance;
+ (DBNamespace *)createNewNamespace;


@end
