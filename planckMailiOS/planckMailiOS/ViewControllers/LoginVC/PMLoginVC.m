//
//  PMLoginVC.m
//  planckMailiOS
//
//  Created by admin on 5/24/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMLoginVC.h"
#import "PMAPIManager.h"
#import "Config.h"

#import "MBProgressHUD.h"

@interface PMLoginVC () <UIWebViewDelegate> {
    __weak IBOutlet UIWebView *_webView;
}
@end

@implementation PMLoginVC

#pragma mark - PMLoginVC lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView setDelegate:self];
    
    NSString *lRedirectUrlString = [NSString stringWithFormat:@"in-%@://app/auth-response", APP_ID];
    NSString *lUrlString = [PMRequest loginWithAppId:APP_ID mail:@"" redirectUri:lRedirectUrlString];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lUrlString]]];
}

#pragma mark - Additional methods

- (void)goToMainVC {
    UITabBarController *lMainTabBar = [STORYBOARD instantiateViewControllerWithIdentifier:@"MainTabBar"];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController pushViewController:lMainTabBar animated:YES];
}

- (void)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIWebView delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSLog(@"shouldStartLoadWithRequest - %@", request.URL.absoluteString);
    NSString *lUrlString = request.URL.absoluteString;
    
    if ([lUrlString hasPrefix:@"in-8lh2dc493h6aq0trdu973kkow://app/auth-response?"]) {
        NSArray *lItems = [lUrlString componentsSeparatedByString:@"="];
        [[PMAPIManager shared] saveNamespaceIdFromToken:[lItems lastObject]];
        [self goToMainVC];
    } else if ([lUrlString hasPrefix:@"about:"]) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
   [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError - %@", error);
}

@end
