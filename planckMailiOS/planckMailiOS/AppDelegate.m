//
//  AppDelegate.m
//  planckMailiOS
//
//  Created by Admin on 5/10/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "AppDelegate.h"

#import "DBManager.h"

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

#pragma mark - Private methods

- (void)setUpCustomDesign {
   [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
}

@end
