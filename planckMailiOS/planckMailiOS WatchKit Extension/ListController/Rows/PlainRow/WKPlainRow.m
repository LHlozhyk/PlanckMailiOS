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
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *mainGroup;

@property (nonatomic, retain) PMTypeContainer *typeContainer;

@end

@implementation WKPlainRow

- (void)setTypeContainer:(PMTypeContainer *)typeContainer {
  _typeContainer = typeContainer;
  
  if([typeContainer.provider length] > 0) {
    NSString *newTitle = [typeContainer.provider substringToIndex:1];
    newTitle = [typeContainer.provider stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[newTitle uppercaseString]];
    [self.titleLable setText:newTitle];
  }
  [self.unreadLable setHidden:typeContainer.unreadCount < 0];
  if(typeContainer.unreadCount >= 0) {
    [self.unreadLable setText:[NSString stringWithFormat:@"%li", typeContainer.unreadCount]];
  }
}

- (void)setTitle:(NSString *)title {
  [self.titleLable setText:title];
  [self.unreadLable setHidden:YES];
}

@end
