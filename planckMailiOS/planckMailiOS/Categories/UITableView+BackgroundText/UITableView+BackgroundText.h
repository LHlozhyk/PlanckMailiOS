//
//  UITableView+BackgroundText.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/4/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (BackgroundText)
- (void)changeBackroundTextInSearcTVC:(BOOL)haveResults withMessage:(NSString *)message;
@end
