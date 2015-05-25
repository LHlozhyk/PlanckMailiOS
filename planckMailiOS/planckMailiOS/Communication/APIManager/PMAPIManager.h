//
//  PMAPIManager.h
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PMRequest.h"

@interface PMAPIManager : NSObject
+ (PMAPIManager *)shared;

- (void)saveNamespaceIdFromToken:(NSString *)token;

@end
