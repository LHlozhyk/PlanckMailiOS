//
//  WKEmailRow.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#define EMAIL_ROW_IDENTIFIER @"emailType"

@class PMInboxMailModel;
@interface WKEmailRow : NSObject

- (void)setEmailContainer:(PMInboxMailModel *)emailContainer;

@end
