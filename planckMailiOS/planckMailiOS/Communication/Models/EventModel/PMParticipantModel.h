//
//  PMParticipantModel.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 9/22/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ParticipantStatuType) {
    ParticipantNoreplyStatus,
    ParticipantNoStatus,
    ParticipantMaybeStatus,
    ParticipantYesStatus,
};

@interface PMParticipantModel : NSObject

@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, assign) ParticipantStatuType statusType;

- (instancetype)initWithDictionary:(NSDictionary *)object;

@end
