//
//  PMAPIManager.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMAPIManager.h"
#import "OPDataLoader.h"
#import "PMRequest.h"

#define TOKEN @"namespaces"

@implementation PMAPIManager

+ (PMAPIManager *)shared {
    static PMAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedManager = [PMAPIManager new];
    });
    return sharedManager;
}

- (void)saveNamespaceIdFromToken:(NSString *)token {
    SAVE_VALUE(token, TOKEN);
    
    OPDataLoader *lDataLoader = [OPDataLoader new];
    [lDataLoader loadUrlWithGETMethod:[PMRequest namespaces] handler:^(NSData *loadData, NSError *error, BOOL success) {
        NSString *response = [[NSString alloc] initWithData:loadData encoding:NSUTF8StringEncoding];
        NSLog(@"User ID is   %@ in - %s", response, __PRETTY_FUNCTION__);
    }];
    
}

@end
