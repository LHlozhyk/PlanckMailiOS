//
//  PMPreviewTableView.h
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 10/10/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMInboxMailModel;
@interface PMPreviewTableView : UIView

@property(nonatomic, strong) PMInboxMailModel *inboxMailModel;
@property(nonatomic, strong) NSArray *messages;

+ (instancetype)newPreviewView;

@end
