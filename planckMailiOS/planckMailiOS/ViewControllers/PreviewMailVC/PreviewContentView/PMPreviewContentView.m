//
//  PMPreviewContentView.m
//  planckMailiOS
//
//  Created by admin on 6/21/15.
//  Copyright (c) 2015 LHlozhyk. All rights reserved.
//

#import "PMPreviewContentView.h"

#define DEFAULT_HTML_TEXT(_object_) [NSString stringWithFormat:@"<!DOCTYPE html>\
<html>\
<head>\
</head>\
<body>\
<hr size='1'>\
<br>\%@</body>\
</html>", _object_]

@interface PMPreviewContentView () <UIWebViewDelegate> {
    __weak IBOutlet UIWebView *_contentWebView;
}
@end

@implementation PMPreviewContentView

- (void)awakeFromNib {
    [super awakeFromNib];
    [_contentWebView.scrollView setScrollEnabled:NO];
    [_contentWebView setDelegate:self];
//    _contentWebView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)showDetail:(NSString *)dataDetail {
    NSString *myHTML = DEFAULT_HTML_TEXT(dataDetail);
    [_contentWebView loadHTMLString:myHTML baseURL:nil];
}

- (NSInteger)contentHeight {
    return [[_contentWebView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.scrollHeight;"]] intValue];
}

#pragma mark - UIWebView delegates

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"didFailLoadWithError");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"shouldStartLoadWithRequest");
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
     NSLog(@"webViewDidFinishLoad");
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webViewDidStartLoad");
}

@end
