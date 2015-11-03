//
//  AlertManager.m
//  Snackr
//
//  Created by Matko Lajbaher on 9/7/15.
//  Copyright (c) 2015 Snackr. All rights reserved.
//

#import "AlertManager.h"
#import <MBProgressHUD.h>

@interface AlertManager ()
@end

@implementation AlertManager
static MBProgressHUD *HUD;

+(void)showErrorMessage:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    
    
    /*ShareReferralCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"shareReferralCodeView"];
     KGModal *kgm = [KGModal sharedInstance];
     vc.delegate = kgm;
     kgm.delegateShareRefferralCode = vc;
     [[KGModal sharedInstance] showWithContentViewController:vc andAnimated:YES];*/
}
+(void) showSuccessMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                    message:msg?msg:@"Submit completed!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
+(void) showInfoMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info"
                                                    message:msg?msg:@"Infomation"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message controller:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:actionOk];
    
    [viewController presentViewController:alert animated:YES completion:nil];
}

+(void)showProgressBarWithTitle:(NSString *)title view:(UIView *)view
{
    HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    
    // Set the hud to display with a color
    
    HUD.color = [UIColor colorWithRed:114.0f/255.0f green:204.0f/255.0f blue:191.0f/255.0f alpha:0.90];
    HUD.labelText = title;
    //HUD.dimBackground = YES;
    
    [HUD show:YES];
}
+(void)hideProgressBar
{
    [HUD hide:YES];
}
@end
