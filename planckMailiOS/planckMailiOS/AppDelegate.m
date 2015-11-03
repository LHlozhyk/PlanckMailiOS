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
#import "AFNetworkActivityIndicatorManager.h"

#import <DropboxSDK/DropboxSDK.h>
#import <BoxContentSDK/BOXContentSDK.h>
#import <OneDriveSDK/OneDriveSDK.h>
#import "PMLocalNotification.h"

@interface AppDelegate () <UIAlertViewDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //TODO: don't remove this code
    //    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    //
    //        UIMutableUserNotificationAction *acceptAction = [UIMutableUserNotificationAction new];
    //        acceptAction.title = @"Okay";
    //        acceptAction.identifier = @"accept";
    //        acceptAction.activationMode = UIUserNotificationActivationModeForeground;
    //        acceptAction.authenticationRequired = NO;
    //
    //        UIMutableUserNotificationAction *declineAction = [UIMutableUserNotificationAction new];
    //        declineAction.title = @"No";
    //        declineAction.identifier = @"decline";
    //        declineAction.activationMode = UIUserNotificationActivationModeForeground;
    //        declineAction.authenticationRequired = NO;
    //
    //        UIMutableUserNotificationCategory *category = [UIMutableUserNotificationCategory new];
    //        [category setActions:@[acceptAction, declineAction] forContext:UIUserNotificationActionContextDefault];
    //        category.identifier = @"invite";
    //
    //        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound
    //                                                                                 categories:[NSSet setWithObjects:acceptAction, declineAction, category, nil]];
    //
    //        [application registerUserNotificationSettings: settings];
    //    }
    
    [self setUpCustomDesign];
    
    [PMLocalNotification setUpNotificationForApplication:application];
    [PMLocalNotification cancelNotifications];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    [PMLocalNotification checkDisabledLocalNotification:^(DisabledLocalNotificationType type) {
        NSString *lStatusString = nil;
        switch (type) {
            case DisabledLocalNotificationTypeAlert: {
                lStatusString = @"Alert Styles";
                break;
            }
            case DisabledLocalNotificationTypeBadge: {
                lStatusString = @"Badge App Icon";
                break;
            }
            case DisabledLocalNotificationTypeSound: {
                lStatusString = @"Sounds";
                break;
            }
            case DisabledLocalNotificationTypeAll: {
                lStatusString = @"Badge App Icon, Sounds, Alert Styles";
                break;
            }
            default:
                break;
        }
        if (lStatusString.length != 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"This app requires access to the %@ selected. Enable in Settings -> Notification Center -> Planck Mail.", lStatusString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Open Settings", nil] show];
        }
    }];
    
	
	// ======================= DropBox Settings ============================
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@DROPBOX_APP_KEY
                            appSecret:@DROPBOX_APP_SECRET
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    // ======================= Box Settings =========================
    [BOXContentClient setClientID:@BOX_CLIENT_ID clientSecret:@BOX_CLIENT_SECRET];
    
    // ======================= OneDrive Settings ====================
    [ODClient setMicrosoftAccountAppId:@ONEDRIVE_APP_ID scopes:@[@"onedrive.readwrite"] ];
    

    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"OPEN_DROPBOX_VIEW" object:nil]];
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [PMLocalNotification cancelNotifications];
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

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    DLog(@"Recieved Notification %@",notif);
}

#pragma mark - Private methods

- (void)setUpCustomDesign {
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor whiteColor]
                                                           }];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:NAVIGATION_BAR_TIN_COLOR];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UITabBar appearance] setTintColor:NAVIGATION_BAR_TIN_COLOR];
}

#pragma mark - UIAlertView delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark - WatchKit Extention

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    
    __block UIBackgroundTaskIdentifier watchKitHandler;
    watchKitHandler = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"backgroundTask"
                                                                   expirationHandler:^{
                                                                       DLog(@"Background handler called. Background tasks expirationHandler called.");
                                                                       [[UIApplication sharedApplication] endBackgroundTask:watchKitHandler];
                                                                       watchKitHandler = UIBackgroundTaskInvalid;
                                                                   }];
    
    [[PMWatchRequestHandler sharedHandler] handleWatchKitExtensionRequest:userInfo reply:reply];
}





// =========================== Custom Method ==========================
+(instancetype)sharedInstance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

@end
