//
//  DBManager.m
//  pfaUkraine
//
//  Created by Admin on 29.10.14.
//  Copyright (c) 2014 Indeema. All rights reserved.
//

#import "DBManager.h"

#define DB_FORM @"DBNamespace"

@implementation DBManager
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [NSManagedObjectContext new];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"planckMailiOS" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"planckMailiOS.sqlite"];
    NSLog(@"storeURL %@", storeURL);
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - save db method

- (void)save {
    NSError *error = nil;
    if (self.managedObjectContext != nil) {
        if ([self.managedObjectContext hasChanges]&&![[self managedObjectContext] save:&error]) {
            NSLog(@"data base error :%@", [error description]);
            NSLog(@"object context :%@", self.managedObjectContext);
            abort();
        }
    }
}

#pragma mark - creates new DB objects methods

+ (DBNamespace *)createNewNamespace {
    DBManager *lDBManager = [DBManager instance];
    DBNamespace *lForm = (DBNamespace *)[NSEntityDescription insertNewObjectForEntityForName:DB_FORM inManagedObjectContext:lDBManager.managedObjectContext];
    
    lForm.id = @"";
    lForm.object = @"";
    lForm.namespace_id = @"";
    lForm.account_id = @"";
    lForm.email_address = @"";
    lForm.name = @"";
    lForm.provider = @"";

    return lForm;
}

#pragma mark - properties
//- (NSArray *)forms {
//    if (_forms == nil) {
//        NSError *lError;
//        NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:DB_FORM
//                                                  inManagedObjectContext:[self managedObjectContext]];
//        [lFetchRequest setEntity:entity];
//        _forms = [[self managedObjectContext] executeFetchRequest:lFetchRequest error:&lError];
//        
//        
//        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"attribute" ascending:NO];
//        lFetchRequest.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//        
//        
//        NSFetchedResultsController *lFetchedResultsController = [[NSFetchedResultsController alloc]
//                                    initWithFetchRequest:lFetchRequest
//                                    managedObjectContext:[DBManager instance].managedObjectContext
//                                    sectionNameKeyPath:nil
//                                    cacheName:@"ListCache"];
//        NSError *error = nil;
//        [lFetchedResultsController performFetch:&error];
//        
//    }
//    return _forms;
//}

- (NSArray *)getForms {
    NSError *lError;
    NSFetchRequest *lFetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:DB_FORM
                                              inManagedObjectContext:[self managedObjectContext]];
    [lFetchRequest setEntity:entity];
    _namespaces = [[self managedObjectContext] executeFetchRequest:lFetchRequest error:&lError];
        
    return _namespaces;
}

+ (void)deleteAllDataFromDB {
    DBManager *lDBManager = [DBManager instance];

    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
    [allCars setEntity:[NSEntityDescription entityForName:DB_FORM inManagedObjectContext:lDBManager.managedObjectContext]];
    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * cars = [lDBManager.managedObjectContext executeFetchRequest:allCars error:&error];
    //error handling goes here
    for (NSManagedObject * car in cars) {
        [lDBManager.managedObjectContext deleteObject:car];
    }
    NSError *saveError = nil;
    [lDBManager.managedObjectContext save:&saveError];
}

#pragma mark - instance

+ (DBManager*)instance {
    static DBManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DBManager new];
    });
    return instance;
}

@end
