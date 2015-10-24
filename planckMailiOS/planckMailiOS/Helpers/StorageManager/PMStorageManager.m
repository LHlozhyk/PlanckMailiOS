//
//  PMStorageManager.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMStorageManager.h"

//info keys
#define ACCOUNT_FOLDERS @"account_folders"
#define ACCOUNT_SCHEDULED_FOLDER_ID @"account_scheduled_folder_id"


@implementation PMStorageManager

#pragma mark - Init

- (instancetype)init {
    if(self = [super init]) {
        
    }
    return self;
}

+ (instancetype)sharedInstance {
    static PMStorageManager *sharedManager = nil;
    static dispatch_once_t dispatchToken;
    dispatch_once(&dispatchToken, ^{
        sharedManager = [PMStorageManager new];
    });
    return sharedManager;
}

#pragma mark - Follow-up methods

/*
 "id": "4zv7pgvihjvuptbwv57kiz62",
 "object": "folder",
 "name": "inbox",
 "display_name": "INBOX",
 "account_id": "awa6ltos76vz5hvphkp8k17nt"
 */

+ (void)setFolders:(NSArray *)folders forAccount:(NSString *)accountId {
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    [accountInfo setObject:folders forKey:ACCOUNT_FOLDERS];
    
    NSString *scheduledId = @"";
    for(NSDictionary *folder in folders) {
        if([[folder[@"display_name"] lowercaseString] isEqualToString:SCHEDULED]) {
            scheduledId = folder[@"id"];
            break;
        }
    }
    [accountInfo setObject:scheduledId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];
    
    [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
}

+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId {
    if(folderId) {
        NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
        [accountInfo setObject:folderId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];
        
        [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
    }
}

+ (NSArray *)getFoldersForAccount:(NSString *)accountId {
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    return [accountInfo objectForKey:ACCOUNT_FOLDERS];
}

+ (NSString *)getScheduledFolderIdForAccount:(NSString *)accountId {
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    return [accountInfo objectForKey:ACCOUNT_SCHEDULED_FOLDER_ID];
}

+ (void)deleteScheduledFolderIdForAccout:(NSString *)accountId {

    NSMutableDictionary *dict =[self infoForAccount:accountId];
    
    [dict removeObjectForKey:ACCOUNT_SCHEDULED_FOLDER_ID];
    
    [[PMStorageManager sharedInstance] writeInfo:dict intoFile:accountId];
    
}

#pragma mark - Private methods

+ (NSMutableDictionary *)infoForAccount:(NSString *)name {
    NSMutableDictionary *accountInfo = [[PMStorageManager sharedInstance] infoFileWithName:name];
    if(!accountInfo) {
        accountInfo = [NSMutableDictionary new];
    }
    return accountInfo;
}

- (NSMutableDictionary *)infoFileWithName:(NSString *)name {
    NSString *fileName = [name stringByAppendingString:@".plist"];
    return [[NSMutableDictionary alloc] initWithContentsOfFile:[self filePath:fileName]];
}

- (void)writeInfo:(NSDictionary *)info intoFile:(NSString *)name {
    if(info) {
        NSString *fileName = [name stringByAppendingString:@".plist"];
        [info writeToFile:[self filePath:fileName] atomically:YES];
    }
}

- (NSString *)filePath:(NSString *)name {
    NSString *filePath = [NSHomeDirectory() stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@", name]];
    return filePath;
}


@end
