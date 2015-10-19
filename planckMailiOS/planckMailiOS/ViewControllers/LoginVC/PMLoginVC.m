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
    
    BOOL _isAddtionalAccount;
    BOOL _isSuccessLogin;
}
@end

@implementation PMLoginVC

#pragma mark - PMLoginVC lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _isAddtionalAccount = NO;
        _isSuccessLogin = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView setDelegate:self];
    
    NSString *lRedirectUrlString = [NSString stringWithFormat:@"in-%@://app/auth-response", APP_ID];
    NSString *lUrlString = [PMRequest loginWithAppId:APP_ID mail:@"" redirectUri:lRedirectUrlString];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:lUrlString]]];
}

#pragma mark - Additional methods

- (void)setAdditionalAccoutn:(BOOL)state {
    _isAddtionalAccount = state;
}

- (void)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (_delegate && [_delegate respondsToSelector:@selector(PMLoginVCDelegate:didSuccessLogin:additionalAccount:)]) {
            [_delegate PMLoginVCDelegate:self didSuccessLogin:_isSuccessLogin additionalAccount:_isAddtionalAccount];
        }
    }];
}

#pragma mark - UIWebView delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL lResult = YES;
    DLog(@"shouldStartLoadWithRequest - %@", request.URL.absoluteString);
    NSString *lUrlString = request.URL.absoluteString;
    
    if ([lUrlString hasPrefix:@"in-5girg6tjmjuenujbsg0lnatlq://app/auth-response?"]) {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"=&"];
        NSArray *lItems = [lUrlString componentsSeparatedByCharactersInSet:set];
        [[PMAPIManager shared] saveNamespaceIdFromToken:lItems[1] completion:^(id error, BOOL success) {
            if (success) {
                _isSuccessLogin = success;
                [self backBtnPressed:nil];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }];
        
        lResult = NO;
    } else if ([lUrlString hasPrefix:@"about:"]) {
        [MBProgressHUD hideHUDForView:_webView animated:YES];
    }
    return lResult;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:_webView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:_webView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    DLog(@"didFailLoadWithError - %@", error);
}

@end
