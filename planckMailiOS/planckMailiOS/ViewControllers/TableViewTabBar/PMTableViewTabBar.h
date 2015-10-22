//
//  PMTableViewTabBar.h
//  planckMailiOS
//
//  Created by admin on 9/1/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, selectedMessages) {
    ImportantMessagesSelected,
    ReadLaterMessagesSelected,
    FollowUpsMessagesSelected
};

@protocol PMTableViewTabBarDelegate <NSObject>
@optional
- (void)messagesDidSelect:(selectedMessages)messages;
@end

@interface PMTableViewTabBar : UIView

@property (weak, nonatomic) IBOutlet UIButton *importantMessagesBtn;
@property (weak, nonatomic) IBOutlet UIButton *readLaterMessageBtn;
@property (weak, nonatomic) IBOutlet UIButton *followUpsMessagesBtn;
@property (nonatomic, weak) UIView *line;

- (void)selectMessages:(selectedMessages)messages;
- (void)hideButtons;

- (IBAction)importantBtnTaped:(id)sender;
- (IBAction)readLaterBtnTaped:(id)sender;
- (IBAction)followUpsBtnTapped:(id)sender;

@property (nonatomic, assign)id <PMTableViewTabBarDelegate> delegate;


@end
