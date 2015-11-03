//
//  PMFilesVC.m
//  planckMailiOS
//
//  Created by admin on 8/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMFilesVC.h"
#import "Config.h"

#import <DropboxSDK/DropboxSDK.h>
#import "PMDropboxFileListViewController.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import "PMBoxFileListViewController.h"
#import "PMGoogleDriveFileListViewController.h"
#import "PMOneDriveFileListViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <OneDriveSDK/OneDriveSDK.h>
#import "PMLocalFileListViewController.h"
#import "PMFilesNC.h"

@interface PMFilesVC () <UITableViewDelegate, UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    
    
    NSArray *_itemsArray;
    GTLServiceDrive *gtlService;
}
@end

@implementation PMFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _itemsArray = @[
                    @{@"icon" : @"mobileIcon",
                      @"title" : @"Your Mobile",
                      @"tag" : @"Mobile"},
                    @{@"icon" : @"dropboxIcon",
                      @"title" : @"Your Dropbox",
                      @"tag" : @"Dropbox"},
                    @{@"icon" : @"boxIcon",
                      @"title" : @"Your Box",
                      @"tag" : @"Box"},
                    @{@"icon" : @"googleDriveIcon",
                      @"title" : @"Your GoogleDrive",
                      @"tag" : @"GoogleDrive"},
                    @{@"icon" : @"oneDriveIcon",
                      @"title" : @"Your OneDrive",
                      @"tag" : @"OneDrive"},
                    ];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.isSelecting = ((PMFilesNC*)self.navigationController).isSelecting;
    if(self.isSelecting)
    {
        UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"closeIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(onClose)];
        [self.navigationItem setLeftBarButtonItem:btnClose animated:NO];
    }
}

-(void)onClose
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CanceledSelectFile" object:nil userInfo:nil];
    }];
}
//TODO: don't remove this code
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
//    if (localNotif == nil)
//        return;
//    localNotif.fireDate = [[NSDate date] dateByAddingTimeInterval:10];
//    localNotif.timeZone = [NSTimeZone defaultTimeZone];
//    
//    localNotif.alertBody = @"Just fired new local notification";
//    localNotif.alertAction = @"New notification";
//    localNotif.category = @"invite";
//    
//    localNotif.soundName = UILocalNotificationDefaultSoundName;
//    localNotif.applicationIconBadgeNumber = 1;
//    // NSDictionary *infoDict = [NSDictionary dictionaryWithObject:item.eventName forKey:ToDoItemKey];
//    NSDictionary *infoDict = @{@"start time": [NSDate date], @"shifted on seconds": @"10"};
//    localNotif.userInfo = infoDict;
//    
//    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
//    NSLog(@"scheduledLocalNotifications are %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *lCell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (lCell == nil) {
        lCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    NSDictionary *lData = _itemsArray[indexPath.section];
    
    lCell.imageView.image = [UIImage imageNamed:lData[@"icon"]];
    lCell.textLabel.text = lData[@"title"];
    [lCell.textLabel setMinimumScaleFactor:0.2f];
    
    return lCell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 9;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = [_itemsArray objectAtIndex:indexPath.section];
    
    NSString *tag = [item objectForKey:@"tag"];
    
    if([tag isEqualToString:@"Dropbox"])
    {
        
        // ========================== Sign up from Dropbox ===========================
        //[[DBSession sharedSession] unlinkAll];
        
        if (![[DBSession sharedSession] isLinked]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dropboxLoginDone) name:@"OPEN_DROPBOX_VIEW" object:nil];
            [[DBSession sharedSession] linkFromController:self];
        }
        else
        {
            PMDropboxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([tag isEqualToString:@"Box"])
    {
        // ========================== Sign up from Box ===========================
        /*NSArray *users1 = [BOXContentClient users];
        if(users1.count>0)
        {
            BOXUser *user = [users1 objectAtIndex:0];
            BOXContentClient *client = [BOXContentClient clientForUser:user];
            
            [client logOut];
        }*/
        
        NSArray *users = [BOXContentClient users];
        
        
        if(users.count>0)
        {
            BOXUser *user = [users objectAtIndex:0];
            BOXContentClient *client = [BOXContentClient clientForUser:user];
            /*if (   ([client.session isKindOfClass:[BOXOAuth2Session class]] && !self.isAppUsers)
                || ([client.session isKindOfClass:[BOXAppUserSession class]] && self.isAppUsers)) {
                [users addObject:user];
            }*/
            
            PMBoxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
            controller.client = client;
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            // Create a new client for the account we want to add.
            BOXContentClient *client = [BOXContentClient clientForNewSession];
            
            [client authenticateWithCompletionBlock:^(BOXUser *user, NSError *error) {
                if (error) {
                    if ([error.domain isEqualToString:BOXContentSDKErrorDomain] && error.code == BOXContentSDKAPIUserCancelledError) {
                        BOXLog(@"Authentication was cancelled, please try again.");
                    } else {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                            message:@"Login failed, please try again"
                                                                           delegate:nil
                                                                  cancelButtonTitle:nil
                                                                  otherButtonTitles:@"OK", nil];
                        [alertView show];
                    }
                } else {
                    BOXContentClient *tmpClient = [BOXContentClient clientForUser:user];
                    
                    PMBoxFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMBoxFileListViewController"];
                    controller.client = tmpClient;
                    controller.isSelecting = self.isSelecting;
                    
                    [self.navigationController pushViewController:controller animated:YES];
                }
            }];
        }
    }
    else if([tag isEqualToString:@"GoogleDrive"])
    {
        // ========================== Sign up from GoogleDrive ===========================
        //[GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME];
        
        // Initialize the Drive API service & load existing credentials from the keychain if available.
        gtlService = [[GTLServiceDrive alloc] init];
        gtlService.authorizer = [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                              clientID:@GOOGLE_CLIENT_ID
                                                          clientSecret:@GOOGLE_CLIENT_SECRET];
        
        
        if (!gtlService.authorizer.canAuthorize) {
            // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
            SEL finishedSelector = @selector(viewController:finishedWithAuthToGoogleDrive:error:);
            GTMOAuth2ViewControllerTouch *authViewController =
            [[GTMOAuth2ViewControllerTouch alloc] initWithScope:kGTLAuthScopeDrive
                                                       clientID:@GOOGLE_CLIENT_ID
                                                   clientSecret:@GOOGLE_CLIENT_SECRET
                                               keychainItemName:@GOOGLE_KEYCHAIN_ITEM_NAME
                                                       delegate:self
                                               finishedSelector:finishedSelector];
            
            [self.navigationController pushViewController:authViewController animated:YES];
        } else {
            PMGoogleDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileListViewController"];
            controller.service = gtlService;
            controller.isSelecting = self.isSelecting;
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if([tag isEqualToString:@"OneDrive"])
    {
       
        //ODClient *currentClient = [ODClient loadCurrentClient];
        //if(currentClient.authProvider)
        //ODClient *oldClient = [ODClient loadCurrentClient];
        //if(oldClient)
        //{
            //[oldClient signOutWithCompletion:^(NSError *signOutError){
        
        NSDate *now = [NSDate date];
        NSDate *lastLoginTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"OneDriveLoginTime"];
        if([now timeIntervalSinceDate:lastLoginTime] > 3600)
        {
            [ODClient authenticatedClientWithCompletion:^(ODClient *client, NSError *error){
                if (!error){
                    [ODClient setCurrentClient:client];
                    
                    NSDate *now = [NSDate date];
                    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];

                    
                    //[ODClient loadClientWithAccountId:client.accountId];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        PMOneDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileListViewController"];
                        controller.client = client;
                        controller.isSelecting = self.isSelecting;
                        
                        [self.navigationController pushViewController:controller animated:YES];
                    });
                }
                else{
                    NSLog(@"OneDrive Authentication canceled!");
                    
                }
            }];
            
        }
        else
        {
            [ODClient clientWithCompletion:^(ODClient *client, NSError *error){
                if (!error){
                    [ODClient setCurrentClient:client];
                    
                    NSDate *now = [NSDate date];
                    [[NSUserDefaults standardUserDefaults] setObject:now forKey:@"OneDriveLoginTime"];
                    
                    //[ODClient loadClientWithAccountId:client.accountId];
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        
                        PMOneDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMOneDriveFileListViewController"];
                        controller.client = client;
                        controller.isSelecting = self.isSelecting;
                        
                        [self.navigationController pushViewController:controller animated:YES];
                    });
                }
                else{
                    NSLog(@"OneDrive Authentication canceled!");
                    
                }
            }];
        }
            //}];
        //}
        
        
        
    }
    else if([tag isEqualToString:@"Mobile"])
    {
        PMLocalFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMLocalFileListViewController"];
        
        controller.isSelecting = self.isSelecting;
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

-(void)dropboxLoginDone
{
    PMDropboxFileListViewController *controller = (PMDropboxFileListViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"PMDropboxFileListViewController"];
    [self.navigationController pushViewController:controller animated:YES];
    
    controller.isSelecting = self.isSelecting;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OPEN_DROPBOX_VIEW" object:nil];
}


// ======= GoogleDrive Delegate ===========
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuthToGoogleDrive:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    //[self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    if (error == nil) {
        [self isAuthorizedWithAuthentication:auth];
        
        PMGoogleDriveFileListViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PMGoogleDriveFileListViewController"];
        controller.service = [self gtlDriveService];
        controller.isSelecting = self.isSelecting;

        
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (GTLServiceDrive *)gtlDriveService {
    static GTLServiceDrive *service = nil;
    
    if (!service) {
        service = [[GTLServiceDrive alloc] init];
        
        // Have the service object set tickets to fetch consecutive pages
        // of the feed so we do not need to manually fetch them.
        service.shouldFetchNextPages = YES;
        
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
    }
    return service;
}
- (void)isAuthorizedWithAuthentication:(GTMOAuth2Authentication *)auth {
    [[self gtlDriveService] setAuthorizer:auth];
}
@end
