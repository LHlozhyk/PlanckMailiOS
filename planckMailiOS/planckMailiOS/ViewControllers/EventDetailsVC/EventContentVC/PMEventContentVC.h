//
//  PMEventContentVC.h
//  planckMailiOS
//
//  Created by Lyubomyr Hlozhyk on 10/13/15.
//  Copyright © 2015 LHlozhyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PMEventModel;
@interface PMEventContentVC : UITableViewController
- (void)updateWithEvent:(PMEventModel*)event;
@end
