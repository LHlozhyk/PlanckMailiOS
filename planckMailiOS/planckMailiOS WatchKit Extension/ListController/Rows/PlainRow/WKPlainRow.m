//
//  WKPlainRow.m
//  planckMailiOS
//
//  Created by Dmytro Nosulich on 7/14/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "WKPlainRow.h"
#import "PMTypeContainer.h"

@interface WKPlainRow ()

@property (nonatomic, weak) IBOutlet WKInterfaceLabel *titleLable;
@property (nonatomic, weak) IBOutlet WKInterfaceLabel *unreadLable;

@property (nonatomic, retain) PMTypeContainer *typeContainer;

@end

@implementation WKPlainRow

- (void)setTypeContainer:(PMTypeContainer *)typeContainer {
  _typeContainer = typeContainer;
  
  [self.titleLable setText:typeContainer.title];
  [self.unreadLable setHidden:typeContainer.unreadCount < 0];
  if(typeContainer.unreadCount >= 0) {
    [self.unreadLable setText:[NSString stringWithFormat:@"%li", typeContainer.unreadCount]];
  }
}

@end
