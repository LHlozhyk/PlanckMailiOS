//
//  PMStorageManager.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SCHEDULED @"Follow_Up"

@interface PMStorageManager : NSObject


#pragma mark - Follow-up methods

+ (void)setFolders:(NSArray *)folders forAccount:(NSString *)accountId;
+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId;
+ (void)deleteScheduledFolderIdForAccout:(NSString *)accountId;
+ (void)setFolderId:(NSString *)folderId forAccount:(NSString*)accountId forKey:(NSString*)key;

+ (NSArray *)getFoldersForAccount:(NSString *)accountId;
+ (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId;
+ (NSString *)getFolderIdForAccount:(NSString *)accountId forKey:(NSString*)key;
@end
/*
if true
  
 + (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId;
 getScheduledFolderIdForAccount  -> namespace_id


 
 else 
 create scheduled folder with name Scheduled (#define SCHEDULED @"scheduled") also (API Method)
 + (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId;


*/