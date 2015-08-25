//
//  AppDelegate.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "AppDelegate.h"

#import "DBManager.h"
#import "PMWatchRequestHandler.h"
#import "Config.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self setUpCustomDesign];
    
    NSArray *lNamespacesArray = [[DBManager instance] getNamespaces];
    if (lNamespacesArray.count > 0) {
        UITabBarController *lMainTabBar = [STORYBOARD instantiateViewControllerWithIdentifier:@"MainTabBar"];
        [(UINavigationController *)self.window.rootViewController setNavigationBarHidden:YES];
        [(UINavigationController *)self.window.rootViewController pushViewController:lMainTabBar animated:NO];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {

}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType {
  return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler {
  return YES;
}

#pragma mark - Private methods

- (void)setUpCustomDesign {
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:NAVIGATION_BAR_TIN_COLOR];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBar appearance] setSelectedImageTintColor:NAVIGATION_BAR_TIN_COLOR];
}

#pragma mark - WatchKit Extention

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {

  __block UIBackgroundTaskIdentifier watchKitHandler;
  watchKitHandler = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backgroundTask"
                                                                 expirationHandler:^{
                                                                   NSLog(@"Background handler called. Background tasks expirationHandler called.");
                                                                   [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
                                                                   watchKitHandler = UIBackgroundTaskInvalid;
                                                                 }];
  
  [[PMWatchRequestHandler sharedHandler] handleWatchKitExtensionRequest:userInfo reply:reply];
}

@end
