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

@class PMEmailContainer;
@interface WKEmailRow : NSObject

- (void)setEmailContainer:(PMEmailContainer *)emailContainer;

@end
