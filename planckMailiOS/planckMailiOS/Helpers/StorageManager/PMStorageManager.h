//
//  PMStorageManager.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PMStorageManager : NSObject

#pragma mark - Follow-up methods

+ (void)setFolders:(NSArray *)folders forAccount:(NSString *)accountId;
+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId;

+ (NSArray *)getFoldersForAccount:(NSString *)accountId;
+ (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId;

@end
