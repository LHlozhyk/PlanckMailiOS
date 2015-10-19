//
//  PMEventDetailsVC.m
//  planckMailiOS
//
//  Created by admin on 9/20/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMEventDetailsVC.h"
#import "UIViewController+PMStoryboard.h"
#import "PMEventModel.h"

#import "PMEventContentVC.h"

@interface PMEventDetailsVC () <UIPageViewControllerDataSource> {
    
    NSArray *_itemsArray;
    PMEventModel *_currentEvent;
}
@property(nonatomic, assign) NSInteger index;
@property(nonatomic, assign) NSUInteger eventsCount;
@property(strong, nonatomic) UIPageViewController *pageController;
@end

@implementation PMEventDetailsVC

- (instancetype)initWithEvent:(PMEventModel *)eventModel index:(NSUInteger)index {
    self = [self initWithStoryboard];
    if (self) {
        _currentEvent = eventModel;
        _index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Event Details"];
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    
    PMEventContentVC *initialViewController = [[PMEventContentVC alloc] initWithStoryboard];
    [initialViewController updateWithEvent:_currentEvent];

    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    if (!_currentEvent.readonly) {
        [self setUpDeleteEventBtn];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSUInteger)eventsCount {
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfEventsInEventDetailsVC:)]) {
        _eventsCount = [_delegate numberOfEventsInEventDetailsVC:self];
    }
    return _eventsCount;
}

#pragma mark - Private methods

- (void)setUpDeleteEventBtn {
    UIImage *buttonImage = [UIImage imageNamed:@"deleted_menu_icon"];
    
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [aButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    aButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width,   buttonImage.size.height);
    
    UIBarButtonItem *aBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    
    [aButton addTarget:self action:@selector(deleteEventBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationItem setRightBarButtonItem:aBarButtonItem];
}

- (void)deleteEventBtnPressed:(id)sender {
    NSLog(@"deleteEventBtnPressed");
}

- (PMEventContentVC *)viewControllerAtIndex:(NSUInteger)index {
    PMEventContentVC *childViewController = [[PMEventContentVC alloc] initWithStoryboard];
    if (_delegate && [_delegate respondsToSelector:@selector(PMEventDetailsVCDelegate:eventByIndex:)]) {
       _currentEvent = [_delegate PMEventDetailsVCDelegate:self eventByIndex:index];
    }
    if (!_currentEvent.readonly) {
        [self setUpDeleteEventBtn];
    } else {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    [childViewController updateWithEvent:_currentEvent];
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if (_index == 0) {
        return nil;
    }
    _index--;
    return [self viewControllerAtIndex:_index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    _index++;
    if (_index == self.eventsCount) {
        return nil;
    }
    
    return  [self viewControllerAtIndex:_index];
    
}

@end
