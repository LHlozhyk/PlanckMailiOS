//
//  PMTypeContainer.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PMTypeContainer : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) NSInteger type;

+ (instancetype)initWithTitle:(NSString *)title count:(NSInteger)count;

@end
