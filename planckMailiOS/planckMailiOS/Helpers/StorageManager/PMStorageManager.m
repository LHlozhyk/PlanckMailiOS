//
//  PMStorageManager.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/21/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import "PMStorageManager.h"
#import "Config.h"

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
            [accountInfo setObject:scheduledId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];

            break;
        }
        else{
        
            scheduledId = folder[@"id"];
            
            DLog(@"displayed_name = %@ folder name = %@ folder id = %@",folder[@"display_name"],folder[@"name"], scheduledId);

            
            //TODO:
            /*
             в accountInfo зберігати окремо масив отаких штук @{"folderName": folderId}, -> ACCOUNT_FOLDERS
             і окремо id scheduled folder ACCOUNT_SCHEDULED_FOLDER_ID
             
             folderName = folder[@"name"](якщо таке існує в іншому випадку folder[@"display_name"])
             
             if якщо немає значення ACCOUNT_SCHEDULED_FOLDER_ID то: {
                кожного разу коли переписується масив фолдерів шукати папку з display_name = SCHEDULED, і якщо така є то запихнути folderId за ключем ACCOUNT_SCHEDULED_FOLDER_ID;
             }
             else {
                якщо є значення ACCOUNT_SCHEDULED_FOLDER_ID то:
                перевірити чи з серед нових фолдерів є фолдер з id який записаний за ключем ACCOUNT_SCHEDULED_FOLDER_ID
                if якщо немає такого фолдера {
                    то видалити значення за ключем ACCOUNT_SCHEDULED_FOLDER_ID (тобто це означає, що користувач видалив папку SCHEDULED)
                } 
                else {
                    якщо є така папка то нічого не робити
                }
             }
             
             */
            
            if (![folder[@"name"] isKindOfClass:[NSNull class]]) {
                [accountInfo setObject:scheduledId forKey:folder[@"name"]];
            }
      
        }
    }
    
    [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
}

+ (void)setScheduledFolderId:(NSString *)folderId forAccount:(NSString *)accountId {
    if(folderId) {
        NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
        [accountInfo setObject:folderId forKey:ACCOUNT_SCHEDULED_FOLDER_ID];
        
        [[PMStorageManager sharedInstance] writeInfo:accountInfo intoFile:accountId];
    }
}

+ (void)setFolderId:(NSString *)folderId forAccount:(NSString*)accountId forKey:(NSString*)key{
    if(folderId) {
        NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
        [accountInfo setObject:folderId forKey:key];
        
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

+ (NSString *)getFolderIdForAccount:(NSString *)accountId forKey:(NSString*)key {
  
    NSMutableDictionary *accountInfo = [self infoForAccount:accountId];
    return [accountInfo objectForKey:key];
    
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
