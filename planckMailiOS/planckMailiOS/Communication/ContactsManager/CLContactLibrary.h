//
//  CLContactLibrary.h
//
//  Created by Chirag Lakhani on 04/03/14.
//  Copyright (c) 2014 Chirag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <AddressBook/ABAddressBook.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABMultiValue.h>
#import "CLPerson.h"

@protocol APContactLibraryDelegate;

@protocol APContactLibraryDelegate <NSObject>
- (void)apGetContactArray:(NSArray *)contactArray;
@optional
- (BOOL)shouldScaleImage;

@end

@interface CLContactLibrary : NSObject


@property(nonatomic,weak)id <APContactLibraryDelegate> delegate;

- (void)getContactArrayForDelegate:(id<APContactLibraryDelegate>)aDelegate;
- (void)getContactArray;

+ (CLContactLibrary *)sharedInstance;
@end
