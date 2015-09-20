//
//  WKContactInfoController.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "WKBaseController.h"

#define CONTACTS_INFO_IDENT @"contactInfoController"

@interface WKContactInfoController : WKBaseController

- (instancetype)initWithContactNames:(NSDictionary *)names;

@end
