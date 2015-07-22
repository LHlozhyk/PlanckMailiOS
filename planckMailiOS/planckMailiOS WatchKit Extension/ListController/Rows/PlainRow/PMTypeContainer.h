//
//  PMTypeContainer.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBNamespace;
@interface PMTypeContainer : NSObject <NSSecureCoding>

@property (nonatomic, assign) NSInteger unreadCount;
@property (nonatomic, assign) BOOL isNameSpace;
@property (nonatomic, copy) NSString * id;
@property (nonatomic, copy) NSString * object;
@property (nonatomic, copy) NSString * namespace_id;
@property (nonatomic, copy) NSString * account_id;
@property (nonatomic, copy) NSString * email_address;
@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * provider;
@property (nonatomic, copy) NSString * token;

+ (instancetype)initWithTitle:(NSString *)title count:(NSInteger)count;
+ (instancetype)initWithNameSpase:(DBNamespace *)nameSpace;

@end
