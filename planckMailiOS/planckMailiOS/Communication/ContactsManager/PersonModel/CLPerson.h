//
//  BSPerson.h
//
//
//  Created by Chirag Lakhani on 03/08/13.
//  Copyright (c) 2013 Chirag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CLPerson : NSObject

@property(nonatomic,strong)NSString *firstName;
@property(nonatomic,strong)NSString *lastName;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *phoneNumber;
@property(nonatomic,strong)UIImage  *personImage;
@property(nonatomic,copy)NSString *fullName;

//@property(nonatomic,strong)NSString  *personID;

@property(nonatomic,strong)NSString  *personImageURl;

@end
